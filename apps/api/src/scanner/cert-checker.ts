import tls from 'tls';
import { X509Certificate } from 'crypto';

export interface CertificateInfo {
  domain: string;
  port: number;
  subject: string;
  issuer: string;
  validFrom: string;
  validTo: string;
  daysRemaining: number;
  isExpiringSoon: boolean;
  status: 'valid' | 'expiring_soon' | 'critical' | 'expired' | 'error';
  error?: string;
  // Deep-probe fields (Phase 2)
  san?: string;
  serialNumber?: string;
  fingerprint256?: string;
  signatureAlgorithm?: string;
  protocol?: string;
  cipher?: string;
}

const SIGNATURE_ALGOS: Record<string, string> = {
  '1.2.840.113549.1.1.5': 'sha1WithRSAEncryption',
  '1.2.840.113549.1.1.11': 'sha256WithRSAEncryption',
  '1.2.840.113549.1.1.12': 'sha384WithRSAEncryption',
  '1.2.840.113549.1.1.13': 'sha512WithRSAEncryption',
  '1.2.840.113549.1.1.10': 'RSASSA-PSS',
  '1.2.840.10045.4.3.1': 'ecdsa-with-SHA1',
  '1.2.840.10045.4.3.2': 'ecdsa-with-SHA256',
  '1.2.840.10045.4.3.3': 'ecdsa-with-SHA384',
  '1.2.840.10045.4.3.4': 'ecdsa-with-SHA512',
  '1.3.101.112': 'Ed25519',
  '1.3.101.110': 'X25519'
};

// Minimal DER walker: Certificate ::= SEQUENCE { tbsCertificate, signatureAlgorithm, ... }
function signatureAlgorithmFromDer(raw: Buffer): string | undefined {
  try {
    let pos = 0;
    const readLength = (): number => {
      let len = raw[pos++];
      if (len & 0x80) {
        const n = len & 0x7f;
        len = 0;
        for (let i = 0; i < n; i++) len = (len << 8) | raw[pos++];
      }
      return len;
    };
    // Outer SEQUENCE
    if (raw[pos++] !== 0x30) return undefined;
    readLength();
    // TBSCertificate SEQUENCE — skip it whole
    if (raw[pos] !== 0x30) return undefined;
    pos++;
    const tbsLen = readLength();
    pos += tbsLen;
    // signatureAlgorithm AlgorithmIdentifier ::= SEQUENCE { OID, ... }
    if (raw[pos] !== 0x30) return undefined;
    pos++;
    readLength();
    if (raw[pos] !== 0x06) return undefined; // OID tag
    pos++;
    const oidLen = readLength();
    const oidBytes = raw.subarray(pos, pos + oidLen);
    // Decode base-128 OID
    const parts: number[] = [];
    let value = 0;
    let first = true;
    for (const b of oidBytes) {
      value = (value << 7) | (b & 0x7f);
      if (!(b & 0x80)) {
        if (first) {
          parts.push(Math.min(2, Math.floor(value / 40)), value - Math.min(2, Math.floor(value / 40)) * 40);
          first = false;
        } else {
          parts.push(value);
        }
        value = 0;
      }
    }
    const oid = parts.join('.');
    return SIGNATURE_ALGOS[oid] || oid;
  } catch {
    return undefined;
  }
}

export class CertChecker {
  /**
   * Probes TLS certificate for a domain:port.
   * Calculates days remaining and expiry warning levels.
   */
  async check(domain: string, port: number = 443, timeoutMs: number = 4000): Promise<CertificateInfo> {
    const cleanDomain = domain.replace(/^\(|\)$/g, '').trim();

    return new Promise((resolve) => {
      let resolved = false;

      const finish = (info: CertificateInfo) => {
        if (resolved) return;
        resolved = true;
        resolve(info);
      };

      const socket = tls.connect(
        {
          host: cleanDomain === 'localhost' ? '127.0.0.1' : cleanDomain,
          port,
          servername: cleanDomain.includes('.') ? cleanDomain : undefined,
          rejectUnauthorized: false,
          timeout: timeoutMs
        },
        () => {
          try {
            const cert = socket.getPeerCertificate();
            // Capture session info before destroying the socket
            const protocol =
              typeof (socket as any).getProtocol === 'function' ? (socket as any).getProtocol() || undefined : undefined;
            const cipherInfo = typeof (socket as any).getCipher === 'function' ? (socket as any).getCipher() : null;
            socket.destroy();

            if (!cert || !cert.valid_to) {
              return finish({
                domain: cleanDomain,
                port,
                subject: 'Unknown',
                issuer: 'Unknown',
                validFrom: '',
                validTo: '',
                daysRemaining: 0,
                isExpiringSoon: false,
                status: 'error',
                error: 'No TLS certificate returned'
              });
            }

            const validToDate = new Date(cert.valid_to);
            const now = new Date();
            const diffTime = validToDate.getTime() - now.getTime();
            const daysRemaining = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            let status: CertificateInfo['status'] = 'valid';
            if (daysRemaining <= 0) {
              status = 'expired';
            } else if (daysRemaining <= 7) {
              status = 'critical';
            } else if (daysRemaining <= 30) {
              status = 'expiring_soon';
            }

            const issuerRaw = typeof cert.issuer === 'object' ? (cert.issuer.O || cert.issuer.CN || 'Unknown') : String(cert.issuer || 'Unknown');
            const subjectRaw = typeof cert.subject === 'object' ? (cert.subject.CN || 'Unknown') : String(cert.subject || 'Unknown');
            const issuer = Array.isArray(issuerRaw) ? issuerRaw.join(', ') : String(issuerRaw);
            const subject = Array.isArray(subjectRaw) ? subjectRaw.join(', ') : String(subjectRaw);

            // Deep-probe extras (SANs, serial, fingerprint, signature algorithm)
            let san: string | undefined;
            let serialNumber: string | undefined;
            let fingerprint256: string | undefined;
            let signatureAlgorithm: string | undefined;
            try {
              san = (cert as any).san || undefined;
              serialNumber = cert.serialNumber || undefined;
              fingerprint256 = cert.fingerprint256 || undefined;
              if (cert.raw) {
                const x509 = new X509Certificate(cert.raw);
                san = san || x509.subjectAltName || undefined;
                serialNumber = serialNumber || x509.serialNumber || undefined;
                fingerprint256 = fingerprint256 || x509.fingerprint256 || undefined;
                signatureAlgorithm = signatureAlgorithmFromDer(cert.raw) || undefined;
              }
            } catch {
              // extras are optional
            }

            const cipher = cipherInfo ? `${cipherInfo.name}${cipherInfo.version ? ' ' + cipherInfo.version : ''}` : undefined;

            finish({
              domain: cleanDomain,
              port,
              subject,
              issuer,
              validFrom: cert.valid_from,
              validTo: cert.valid_to,
              daysRemaining,
              isExpiringSoon: daysRemaining <= 30,
              status,
              san,
              serialNumber,
              fingerprint256,
              signatureAlgorithm,
              protocol,
              cipher
            });
          } catch (e: any) {
            socket.destroy();
            finish({
              domain: cleanDomain,
              port,
              subject: 'Unknown',
              issuer: 'Unknown',
              validFrom: '',
              validTo: '',
              daysRemaining: 0,
              isExpiringSoon: false,
              status: 'error',
              error: e.message
            });
          }
        }
      );

      socket.on('timeout', () => {
        socket.destroy();
        finish({
          domain: cleanDomain,
          port,
          subject: 'Unknown',
          issuer: 'Unknown',
          validFrom: '',
          validTo: '',
          daysRemaining: 0,
          isExpiringSoon: false,
          status: 'error',
          error: `TLS probe timed out after ${timeoutMs}ms`
        });
      });

      socket.on('error', (err) => {
        finish({
          domain: cleanDomain,
          port,
          subject: 'Unknown',
          issuer: 'Unknown',
          validFrom: '',
          validTo: '',
          daysRemaining: 0,
          isExpiringSoon: false,
          status: 'error',
          error: err.message
        });
      });
    });
  }
}

export const certChecker = new CertChecker();
