import { useCallback, useContext, useEffect, useState } from "react";
import CurrentAccountContext from "../../context/CurrentAccountProvider";
import { useContract } from "../../hooks/useContract";
import styles from "./ViewBuyersForm.module.css";

export default function ViewBuyersForm() {
  const [currentAccount] = useContext(CurrentAccountContext);
  const { assetTokenization } = useContract({ currentAccount });

  const [buyers, setBuyers] = useState<string[]>([]);

  const BuyersCard = ({ buyer }: { buyer: string }) => {
    return (
      <div>
        <p>{buyer}</p>
      </div>
    );
  };

  const getBuyers = useCallback(async () => {
    if (!currentAccount) {
      alert("connect wallet");
      return;
    }
    if (!assetTokenization) return;
    const available = await assetTokenization.availableContract(currentAccount);
    if (!available) return;
    try {
      const buyers = await assetTokenization.getBuyers();
      setBuyers(buyers);
    } catch (error) {
      alert(error);
    }
  }, [currentAccount, assetTokenization]);

  useEffect(() => {
    getBuyers();
  }, [getBuyers]);

  return (
    <div className={styles.container}>
      <p>Addresses of people who bought your NFT: </p>
      {buyers.map((buyer, index) => {
        return (
          <div key={index}>
            <BuyersCard buyer={buyer} />
          </div>
        );
      })}
    </div>
  );
}