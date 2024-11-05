import React, { useContext } from "react";
import { TransactionContext } from "../context/TransactionContext";
import Loader from "./Loader";

const Input = ({ placeholder, name, type, value, handleChange, regex }) => {
  const handleInputChange = (e) => {
    const inputValue = e.target.value;
    if (regex) {
      const re = new RegExp(regex);
      if (re.test(inputValue) || inputValue === "") {
        handleChange(e, name);
      }
    } else {
      handleChange(e, name);
    }
  };

  return (
    <input
      placeholder={placeholder}
      type={type}
      step="0.0001"
      value={value}
      onChange={handleInputChange}
      className="my-2 w-full rounded-sm p-2 outline-none bg-transparent text-white border-none text-sm white-glassmorphism"
    />
  );
};

const Welcome = () => {
  const {
    handleChange,
    formData,
    isLoading,
    zkProof,
    zkResult,
    publicSignals,
    setPublicSignals,
    generateProof,
    sendTransaction,
    proofGenerated,
  } = useContext(TransactionContext);

  const handleGenerateProof = async (e) => {
    e.preventDefault();
    await generateProof(); // Generate proof when "Generate Proof" is clicked
  };

  const handlePublicSignalsChange = (e) => {
    setPublicSignals(JSON.parse(e.target.value)); // Handle changes to the public signals
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    await sendTransaction(); // Send transaction when "Send Now" is clicked
  };

  return (
    <div className="flex w-full justify-center items-center">
      <div className="flex mf:flex-row flex-col items-start justify-between md:p-20 py-12 px-4">
        <div className="flex flex-1 justify-start items-start flex-col mf:mr-10">
          <h1 className="text-3xl sm:text-5xl text-white text-gradient py-1">
            Secure Transactions with zk-SNARKs and RLWE
          </h1>
          <p className="text-sm text-left mt-5 text-white md:w-11/12 w-11/12 font-bold text-base">
            Utilize post-quantum cryptography to secure your transactions with cutting-edge technologies 
            like zk-SNARKs and Ring-Learning With Errors (RLWE). zk-SNARKs (Zero-Knowledge Succinct Non-Interactive Arguments of Knowledge) 
            ensure that transactions are verified without revealing any underlying data, providing enhanced privacy and efficiency. 
            Coupled with RLWE, which offers robust security against potential quantum computing threats, these technologies represent 
            the forefront of cryptographic innovation. This combination not only safeguards your data from current and future threats 
            but also ensures a secure and scalable framework for financial transactions in the digital age.
          </p>
        </div>

        <div className="flex flex-col flex-1 items-center justify-start w-full mf:mt-0 mt-10">
          <div className="p-5 sm:w-96 w-full flex flex-col justify-start items-center blue-glassmorphism">
            <Input
              placeholder="Address To"
              name="addressTo"
              type="text"
              value={formData.addressTo}
              handleChange={handleChange}
            />
            <Input
              placeholder="Amount (ETH)"
              name="amount"
              type="number"
              value={formData.amount}
              handleChange={handleChange}
            />
            <Input
              placeholder="Enter Message (in bits)"
              name="message"
              type="text"
              value={formData.message}
              handleChange={handleChange}
              regex="^[01]+$" // Only allow binary digits (0 and 1)
            />

            <div className="h-[1px] w-full bg-gray-400 my-2" />

            {isLoading ? (
              <Loader />
            ) : proofGenerated ? (
              <button
                type="button"
                onClick={handleSubmit}
                className="text-white w-full mt-2 border-[1px] p-2 border-[#3d4f7c] hover:bg-[#3d4f7c] rounded-full cursor-pointer"
              >
                Send Now
              </button>
            ) : (
              <button
                id="proofbutton"
                type="button"
                onClick={handleGenerateProof}
                className="text-white w-full mt-2 border-[1px] p-2 border-[#3d4f7c] hover:bg-[#3d4f7c] rounded-full cursor-pointer"
              >
                Generate Proof
              </button>
            )}
          </div>

          {zkProof && (
            <div className="p-5 sm:w-96 w-full flex flex-col justify-start items-center blue-glassmorphism mt-5">
              <h3 className="text-white font-semibold text-lg">zk-SNARK Proof</h3>
              <textarea
                className="w-full p-2 bg-gray-800 text-white rounded-md"
                rows="6"
                value={JSON.stringify(zkProof, null, 2)}
                readOnly
              />
            </div>
          )}

          {publicSignals && (
            <div className="p-5 sm:w-96 w-full flex flex-col justify-start items-center blue-glassmorphism mt-5">
              <h3 className="text-white font-semibold text-lg">Public Signals</h3>
              <textarea
                className="w-full p-2 bg-gray-800 text-white rounded-md"
                rows="4"
                value={JSON.stringify(publicSignals, null, 2)}
                onChange={handlePublicSignalsChange} // Allow editing public signals
              />
            </div>
          )}

          {zkResult !== null && (
              <div className="p-5 sm:w-96 w-full flex flex-col justify-start items-center blue-glassmorphism mt-5">
              <h3 className="text-white font-semibold text-lg">zk-SNARK Verification Result</h3>
              <p className={`font-semibold text-lg mt-2 ${zkResult ? 'text-green-500' : 'text-red-500'}`}>
                {zkResult ? "Verification Passed" : "Verification Failed"}
              </p>
          </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Welcome;
