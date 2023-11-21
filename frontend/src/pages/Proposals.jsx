import React from "react";
import AllProposals from "../components/AllProposals";
import daoAbi from "../abis/daoAbi.json";

const Proposals = () => {
  const contractAddress = daoAbi.address;
  const abi = daoAbi.abi;
  return (
    <div className="max-sm:w-full max-w-[1400px] mx-auto">
      <AllProposals contractAddress={contractAddress} abi={abi} />
    </div>
  );
};

export default Proposals;
