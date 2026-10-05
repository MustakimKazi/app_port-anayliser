import tls from 'tls';

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

            finish({
              domain: cleanDomain,
              port,
              subject,
              issuer,
              validFrom: cert.valid_from,
              validTo: cert.valid_to,
              daysRemaining,
              isExpiringSoon: daysRemaining <= 30,
              status
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
