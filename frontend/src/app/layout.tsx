import type { Metadata } from "next";
import { I18nProvider, LANGUAGE_BOOT_SCRIPT } from "@/lib/i18n";
import { AuthProvider } from "@/lib/auth";
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
import "@/styles/theme.css";

export const metadata: Metadata = {
  title: "EventFlow — ISET Nabeul",
  description: "Plateforme de gestion des événements étudiants de l'ISET Nabeul",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr" dir="ltr">
      <head>
        {/* eslint-disable-next-line @next/next/no-css-tags */}
        <link id="bootstrap-css" rel="stylesheet" href="/vendor/bootstrap.min.css" />
        {/* eslint-disable-next-line @next/next/no-css-tags */}
        <link rel="stylesheet" href="/vendor/bootstrap-icons.min.css" />
        <script dangerouslySetInnerHTML={{ __html: LANGUAGE_BOOT_SCRIPT }} />
      </head>
      <body className="d-flex flex-column min-vh-100">
        <I18nProvider>
          <AuthProvider>
            <Navbar />
            <main className="flex-grow-1">{children}</main>
            <Footer />
          </AuthProvider>
        </I18nProvider>
      </body>
    </html>
  );
}
