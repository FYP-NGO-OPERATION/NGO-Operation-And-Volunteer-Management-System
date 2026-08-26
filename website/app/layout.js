import { Poppins } from "next/font/google";
import Navbar from "../components/layout/Navbar";
import Footer from "../components/layout/Footer";
import { Providers } from "./providers";
import BackgroundEffects from "../components/ui/BackgroundEffects";
import "./globals.css";

const poppins = Poppins({
  weight: ["300", "400", "500", "600", "700", "800", "900"],
  subsets: ["latin"],
  variable: "--font-family",
});

export const metadata = {
  title: "HRAS - Humanitarian Relief and Aid Society",
  description: "Join us in making a real impact. Donate, volunteer, and track transparency with HRAS.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" suppressHydrationWarning className={poppins.variable}>
      <body>
        <Providers>
          <BackgroundEffects />
          <Navbar />
          <main>{children}</main>
          <Footer />
        </Providers>
      </body>
    </html>
  );
}
