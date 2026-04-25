'use client';
import styles from './Button.module.css';

export default function Button({
  children,
  variant = 'primary',
  size = 'md',
  icon,
  iconRight,
  fullWidth,
  loading,
  disabled,
  href,
  ...props
}) {
  const cls = [
    styles.btn,
    styles[variant],
    styles[size],
    fullWidth && styles.full,
    loading && styles.loading,
  ].filter(Boolean).join(' ');

  if (href) {
    return (
      <a href={href} className={cls} {...props}>
        {icon && <span className={styles.icon}>{icon}</span>}
        <span>{children}</span>
        {iconRight && <span className={styles.icon}>{iconRight}</span>}
      </a>
    );
  }

  return (
    <button className={cls} disabled={disabled || loading} {...props}>
      {loading && <span className={styles.spinner} />}
      {icon && !loading && <span className={styles.icon}>{icon}</span>}
      <span>{children}</span>
      {iconRight && <span className={styles.icon}>{iconRight}</span>}
    </button>
  );
}
