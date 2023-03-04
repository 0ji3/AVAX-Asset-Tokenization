import "../styles/globals.css";
import { CurrentAccountProvider } from "../context/CurrentAccountProvider";
import type { AppProps } from "next/app";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <CurrentAccountProvider>
      <Component {...pageProps} />
    </CurrentAccountProvider>
  );
}

export default MyApp;