import { DownloadSection } from '@/components/DownloadSection';
import { Faq } from '@/components/Faq';
import { FeatureGrid } from '@/components/FeatureGrid';
import { Hero } from '@/components/Hero';
import { ScreenshotShowcase } from '@/components/ScreenshotShowcase';

export default function Home() {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'Bumblebee',
    applicationCategory: 'SecurityApplication',
    operatingSystem: 'macOS, Linux',
    softwareVersion: '1.0.1',
    description:
      'A desktop endpoint inventory app for local package scans, diagnostics, and exposure catalog review.',
    url: 'https://bumblebee.drmhse.com',
    downloadUrl:
      'https://github.com/drmhse/bumblebee-ui/releases/latest',
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD',
    },
    publisher: {
      '@type': 'Organization',
      name: 'drmhse',
      url: 'https://github.com/drmhse',
    },
  };

  return (
    <main>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <Hero />
      <FeatureGrid />
      <ScreenshotShowcase />
      <Faq />
      <DownloadSection />
    </main>
  );
}
