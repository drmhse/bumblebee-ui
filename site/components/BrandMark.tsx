import Image from 'next/image';

export function BrandMark({ compact = false }: { compact?: boolean }) {
  return (
    <div className={compact ? 'brand brand-compact' : 'brand'}>
      <Image
        src="/brand/bumblebee-logo.png"
        alt=""
        width={compact ? 44 : 58}
        height={compact ? 44 : 58}
        priority
      />
      <div>
        <strong>BUMBLEBEE</strong>
        <span>ENDPOINT INVENTORY</span>
      </div>
    </div>
  );
}
