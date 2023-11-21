import React from "react";
import AllCampaigns from "../components/AllCampaigns";
import goEth from "../abis/goEth.json";

const Campaigns = () => {
  const contractAddress = goEth.address;
  const abi = goEth.abi;
  return (
    <>
      <div className="max-sm:w-full max-w-[1400px] mx-auto">
        <AllCampaigns contractAddress={contractAddress} abi={abi} />
      </div>
    </>
  );
};

export default Campaigns;
