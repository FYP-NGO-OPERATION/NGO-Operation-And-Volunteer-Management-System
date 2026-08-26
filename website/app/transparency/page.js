import { ShieldCheck, ArrowDownRight, ArrowUpRight, CheckCircle2 } from "lucide-react";

export const metadata = {
  title: "Transparency Ledger | HRAS",
  description: "View our live transparency ledger. 100% of your donation goes directly to relief efforts.",
};

const LEDGER_ENTRIES = [
  { id: "tx-1", type: "IN", amount: 500, label: "Donation via Website", date: "2 mins ago", status: "Verified" },
  { id: "tx-2", type: "OUT", amount: 1250, label: "Medical Supplies (South Floods)", date: "15 mins ago", status: "Deployed" },
  { id: "tx-3", type: "IN", amount: 100, label: "Donation via App", date: "1 hour ago", status: "Verified" },
  { id: "tx-4", type: "IN", amount: 2500, label: "Corporate Match", date: "3 hours ago", status: "Verified" },
  { id: "tx-5", type: "OUT", amount: 3400, label: "Water Filtration Kits", date: "5 hours ago", status: "Deployed" },
  { id: "tx-6", type: "IN", amount: 50, label: "Anonymous Donation", date: "6 hours ago", status: "Verified" },
];

export default function TransparencyPage() {
  return (
    <div className="page-wrapper pt-24" style={{ minHeight: '100vh', backgroundColor: 'var(--bg)' }}>
      {/* Header */}
      <section className="text-center" style={{ padding: '60px 20px 40px' }}>
        <div className="container">
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '10px', padding: '10px 20px', backgroundColor: 'rgba(26, 107, 60, 0.1)', borderRadius: '30px', color: 'var(--primary)', marginBottom: '20px', fontWeight: 600 }}>
            <ShieldCheck size={20} />
            <span>0% Admin Fees Deducted</span>
          </div>
          <h1 style={{ fontSize: '3.5rem', fontWeight: 800, marginBottom: '20px' }}>Live Transparency Ledger</h1>
          <p style={{ fontSize: '1.2rem', color: 'var(--text-secondary)', maxWidth: '700px', margin: '0 auto' }}>
            We believe you deserve to know exactly where your money goes. Every donation and expenditure is tracked publicly on this ledger.
          </p>
        </div>
      </section>

      {/* Stats Row */}
      <section style={{ padding: '0 20px 40px' }}>
        <div className="container" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px' }}>
          <div className="glass-panel" style={{ padding: '30px', borderRadius: '20px', textAlign: 'center' }}>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '10px', fontWeight: 500 }}>Total Raised (30 days)</p>
            <h2 style={{ fontSize: '2.5rem', color: 'var(--text-primary)', margin: 0 }}>$142,500</h2>
          </div>
          <div className="glass-panel" style={{ padding: '30px', borderRadius: '20px', textAlign: 'center' }}>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '10px', fontWeight: 500 }}>Total Deployed (30 days)</p>
            <h2 style={{ fontSize: '2.5rem', color: 'var(--text-primary)', margin: 0 }}>$138,200</h2>
          </div>
          <div className="glass-panel" style={{ padding: '30px', borderRadius: '20px', textAlign: 'center' }}>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '10px', fontWeight: 500 }}>Active Volunteers</p>
            <h2 style={{ fontSize: '2.5rem', color: 'var(--text-primary)', margin: 0 }}>1,240</h2>
          </div>
        </div>
      </section>

      {/* Ledger Table */}
      <section style={{ padding: '0 20px 100px' }}>
        <div className="container">
          <div className="glass-panel" style={{ borderRadius: '20px', overflow: 'hidden' }}>
            <div style={{ padding: '20px 30px', borderBottom: '1px solid var(--border)', backgroundColor: 'var(--bg-secondary)' }}>
              <h3 style={{ margin: 0, fontSize: '1.2rem' }}>Recent Transactions</h3>
            </div>
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                <thead>
                  <tr style={{ color: 'var(--text-hint)', fontSize: '0.9rem', borderBottom: '1px solid var(--border)' }}>
                    <th style={{ padding: '20px 30px', fontWeight: 500 }}>Type</th>
                    <th style={{ padding: '20px 30px', fontWeight: 500 }}>Description</th>
                    <th style={{ padding: '20px 30px', fontWeight: 500 }}>Amount</th>
                    <th style={{ padding: '20px 30px', fontWeight: 500 }}>Time</th>
                    <th style={{ padding: '20px 30px', fontWeight: 500 }}>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {LEDGER_ENTRIES.map((tx) => (
                    <tr key={tx.id} style={{ borderBottom: '1px solid var(--border)' }}>
                      <td style={{ padding: '20px 30px' }}>
                        {tx.type === "IN" ? (
                          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', color: 'var(--primary)', backgroundColor: 'rgba(26, 107, 60, 0.1)', padding: '5px 10px', borderRadius: '15px', fontSize: '0.85rem', fontWeight: 600 }}>
                            <ArrowDownRight size={14} /> IN
                          </div>
                        ) : (
                          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', color: '#ef4444', backgroundColor: 'rgba(239, 68, 68, 0.1)', padding: '5px 10px', borderRadius: '15px', fontSize: '0.85rem', fontWeight: 600 }}>
                            <ArrowUpRight size={14} /> OUT
                          </div>
                        )}
                      </td>
                      <td style={{ padding: '20px 30px', fontWeight: 500 }}>{tx.label}</td>
                      <td style={{ padding: '20px 30px', fontWeight: 700, color: 'var(--text-primary)' }}>
                        {tx.type === "IN" ? "+" : "-"}${tx.amount.toLocaleString()}
                      </td>
                      <td style={{ padding: '20px 30px', color: 'var(--text-secondary)', fontSize: '0.95rem' }}>{tx.date}</td>
                      <td style={{ padding: '20px 30px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                          <CheckCircle2 size={16} color="var(--primary)" /> {tx.status}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div style={{ padding: '20px', textAlign: 'center', backgroundColor: 'var(--bg-secondary)', borderTop: '1px solid var(--border)' }}>
              <button className="btn btn-outline">Load More Transactions</button>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
