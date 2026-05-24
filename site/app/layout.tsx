import type { Metadata, Viewport } from 'next';
import './globals.css';

const siteUrl = 'https://bumblebee.drmhse.com';
const title = 'Bumblebee - Endpoint Inventory for Developer Machines';
const description =
  'Bumblebee scans local developer endpoints for package inventory, diagnostics, and known exposure catalog matches.';

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title,
  description,
  applicationName: 'Bumblebee',
  authors: [{ name: 'drmhse' }],
  creator: 'drmhse',
  publisher: 'drmhse',
  keywords: [
    'Bumblebee',
    'endpoint inventory',
    'package inventory',
    'developer security',
    'macOS scanner',
    'Linux scanner',
    'software supply chain',
    'threat catalog',
  ],
  alternates: {
    canonical: '/',
  },
  icons: {
    icon: [
      { url: '/brand/bumblebee-logo.svg', type: 'image/svg+xml' },
      { url: '/brand/bumblebee-logo.png', type: 'image/png' },
    ],
    apple: [{ url: '/brand/bumblebee-logo.png' }],
  },
  openGraph: {
    type: 'website',
    url: siteUrl,
    siteName: 'Bumblebee',
    title,
    description,
    images: [
      {
        url: '/og/bumblebee-og.png',
        width: 1200,
        height: 630,
        alt: 'Bumblebee endpoint inventory app',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title,
    description,
    images: [
      {
        url: '/og/bumblebee-og.png',
        width: 1200,
        height: 630,
        alt: 'Bumblebee endpoint inventory app',
      },
    ],
  },
  category: 'technology',
};

export const viewport: Viewport = {
  themeColor: '#0b0c0d',
  colorScheme: 'dark',
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <head>
        <script async src="https://www.googletagmanager.com/gtag/js?id=G-6H23BJ2PZS" />
        <script
          dangerouslySetInnerHTML={{
            __html: `
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-6H23BJ2PZS');
`,
          }}
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
