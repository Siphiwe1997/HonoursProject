import React, { createContext, useState } from "react";
import { ethers } from "ethers";
import * as snarkjs from "snarkjs";
import RLWE from "../encryption/rlweEncryption";
import { CONSTRACT } from "../utils/constants";
import { prepareContractCall } from "thirdweb";
import { useSendTransaction } from "thirdweb/react";

export const TransactionContext = createContext();

export const TransactionProvider = ({ children }) => {
  const [formData, setFormData] = useState({
    addressTo: "",
    amount: "",
    message: "",
  });
  const [isLoading, setIsLoading] = useState(false);
  const [zkProof, setZkProof] = useState(null);
  const [zkResult, setZkResult] = useState(null);
  const [publicSignals, setPublicSignals] = useState(null);
  const [proofGenerated, setProofGenerated] = useState(false);

  const { mutate: sendTransaction } = useSendTransaction();

  const handleChange = (e, name) => {
    setFormData((prevState) => ({ ...prevState, [name]: e.target.value }));
  };

  const generateProof = async () => {
    setIsLoading(true);
    try {
      const inputSignals = {
        scalar: 5000,
        base: [982451653, 1000000007, 1000000009, 1000000033],
        secretKey: [1, 5, 7, 4],
        publicPoly: [8, 7, 6, 5],
        rand: [1, 2, 0, 4],
        gaussianNoise: [1, -2, -1, 3],
        leaves: [7393, 73937, 73937, 739, 739393, 2310, 30030, 210],
        leaf: 7393,
        commitments: [
          608306554891316,
          619172004334204,
          619172005572548,
          619172020432676,
        ],
        pathIndices: [0, 0, 0],
      };

      const { proof, publicSignals } = await snarkjs.groth16.fullProve(
        inputSignals,
        "../zkProof/scalarSumProofWithRLWE.wasm",
        "../zkProof/scalarSumProofWithRLWE_0001.zkey"
      );

      setZkProof(proof);
      setPublicSignals(publicSignals);
      setProofGenerated(true);
    } catch (error) {
      console.error("Error generating zk-SNARK proof:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const mapProofToContractFormat = (proof) => {
    const convertToBigIntString = (value) => {
      try {
        if (!/^\d+$/.test(value)) {
          throw new Error(`Invalid number format: ${value}`);
        }
        return BigInt(value).toString();
      } catch (error) {
        console.error(`Error converting value to BigInt: ${error.message}`);
        throw error;
      }
    };

    try {
      const proofObject = {
        a: proof.pi_a.slice(0, 2).map(convertToBigIntString),
        b: proof.pi_b.slice(0, 2).map((row) =>
          row.slice(0, 2).map(convertToBigIntString)
        ),
        c: proof.pi_c.slice(0, 2).map(convertToBigIntString),
      };
      console.log("Formatted proof for contract:", proofObject);
      return proofObject;
    } catch (error) {
      console.error("Error mapping proof to contract format:", error);
      throw error;
    }
  };

  const sendTransactionHandler = async () => {
    if (!zkProof || !publicSignals) {
      return alert("Proof has not been generated or public signals are missing.");
    }

    if (!zkProof.pi_a || !zkProof.pi_b || !zkProof.pi_c) {
      alert("zkProof is not properly structured.");
      setIsLoading(false);
      return;
    }

    setIsLoading(true);
    try {
      const vkey = await fetch("../zkProof/verification_key.json").then((res) =>
        res.json()
      );
      const isValid = await snarkjs.groth16.verify(vkey, publicSignals, zkProof);

      setZkResult(isValid);

      if (!isValid) {
        alert("zk-SNARK verification failed!");
        setIsLoading(false);
        return;
      }

      const { addressTo, amount, message } = formData;
      const parsedAmount = ethers.utils.parseUnits(amount, 18);

      const rlwe = new RLWE(512, 12289, 3.2);
      const encryptedMessage = rlwe.encrypt(message, rlwe.keygen());
      const encryptedMessageString = JSON.stringify(encryptedMessage);

      const formattedProof = mapProofToContractFormat(zkProof);

      const publicSignalsArray = publicSignals.map((signal) =>
        ethers.BigNumber.from(signal).toString()
      );

      console.log("Public signals:", publicSignalsArray);
      console.log("a", formattedProof.a);
      console.log("b", formattedProof.b);
      console.log("c", formattedProof.c);

      if (publicSignalsArray.length !== 33) {
        throw new Error("Public signals array should have exactly 33 elements.");
      }

      const transaction = prepareContractCall({
        contract: CONSTRACT,
        method: "sendTransaction",
        params: [
          addressTo,
          parsedAmount.toString(),
          encryptedMessageString,
          formattedProof.a,
          formattedProof.b,
          formattedProof.c,
          publicSignalsArray,
        ],
      });

      console.log("Prepared transaction object:", transaction);
      const dataPayload = await transaction.data();
      console.log("Prepared transaction data:", dataPayload);

      sendTransaction(transaction, {
        onSuccess: (txReceipt) => {
          alert("Transaction sent successfully!");
          console.log(txReceipt);
        },
        onError: (error) => {
          console.error("Error sending transaction:", error);
          alert(`Transaction failed: ${error.message || error.data || "Unknown error"}`);
        },
      });
    } catch (error) {
      console.error("Error preparing transaction:", error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <TransactionContext.Provider
      value={{
        address: formData.addressTo,
        handleChange,
        generateProof,
        sendTransaction: sendTransactionHandler,
        formData,
        isLoading,
        zkProof,
        zkResult,
        publicSignals,
        setPublicSignals,
        proofGenerated,
      }}
    >
      {children}
    </TransactionContext.Provider>
  );
};
