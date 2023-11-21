import React, { useEffect, useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { useAddress, useContract, useContractRead } from "@thirdweb-dev/react";
import { Toaster, toast } from "react-hot-toast";
import { ethers } from "ethers";
import CreateProposal from "./CreateProposal";
import ProposalCard from "./ProposalCard";
import { MutatingDots } from "react-loader-spinner";

const AllProposals = ({ contractAddress, abi }) => {
  const { contract } = useContract(contractAddress, abi);
  const address = useAddress();
  const [createProposalModal, setCreateProposalModal] = useState(false);
  const [proposalData, setProposalData] = useState([]);
  const { data, isLoading, error } = useContractRead(
    contract,
    "getAllProposals"
  );

  async function showModal() {
    if (address) {
      setCreateProposalModal(true);
    } else {
      toast.error("Wallet not connected");
    }
  }

  async function closeModal() {
    setCreateProposalModal(false);
  }

  async function getAllProposals() {
    // Filter for only active and ended
    const proposals = data.map((proposal) => {
      return {
        id: proposal.id_.toNumber(),
        title: proposal.title,
        description: proposal.description,
        image: proposal.tokenUri,
        target: ethers.utils.formatEther(proposal.fundingGoal),
        raised: ethers.utils.formatEther(proposal.fundingBalance),
        endAt: new Date(proposal.durationTime.toNumber() * 1000),
        status: proposal.isActive,
        owner: proposal.owner,
      };
    });
    //   const today = new Date();
    const activeProposals = proposals.filter(
      (proposal) => proposal.status === true
    );
    setProposalData(activeProposals);
  }
  useEffect(() => {
    getAllProposals();
  }, [data]);

  const reversedProposalData = [...proposalData].reverse();

  return (
    <>
      <Toaster />
      <div className="mt-4 md:mt-4 md:text-left text-center">
        <div className="flex md:w-full md:justify-between justify-space-between mx-auto flex-wrap-reverse w-1/2">
          <h1 className="text-center md:text-4xl md:font-semibold text-[#1c1c24] dark:text-white text-xl md:p-0 py-5">
            Active Proposals
          </h1>
          <button className="relative mt-4 md:mx-20 rounded-xl border-4 overflow-hidden group p-2 text-green-500 font-semibold hover:text-white">
            <div className="absolute w-full h-full  bg-green-500 left-0 top-0 transform translate-x-full group-hover:translate-x-0 transition-transform duration-500"></div>
            <div className="absolute w-full h-full  bg-green-500 left-0 top-0 transform -translate-x-full group-hover:translate-x-0 transition-transform duration-500"></div>
            <div className="absolute w-full h-full  bg-green-500 left-0 top-0 transform -translate-y-full group-hover:translate-y-0 transition-transform duration-500"></div>
            <div className="absolute w-full h-full   bg-green-500 left-0 top-0 transform translate-y-full group-hover:translate-y-0 transition-transform duration-500"></div>
            <span className="relative" onClick={showModal}>
              Create Proposal
            </span>
          </button>
        </div>
        {isLoading && (
          <div className="flex justify-center h-screen">
            <MutatingDots
              height="100"
              width="100"
              color="#1dc071"
              secondaryColor="#1dc071"
              radius="12.5"
              ariaLabel="mutating-dots-loading"
              wrapperStyle={{}}
              wrapperClass=""
              visible={true}
            />{" "}
          </div>
        )}
        {error && <p>Error Loading Proposal</p>}
        {!isLoading && !error && (
          <div className="grid md:grid-cols-3 gap-10 pt-4 justify-center items-center">
            {reversedProposalData.map((data) => (
              <ProposalCard
                key={uuidv4()}
                data={data}
                contractAddress={contractAddress}
                abi={abi}
              />
            ))}
          </div>
        )}
      </div>
      {createProposalModal && (
        <CreateProposal
          showModal={showModal}
          closeModal={closeModal}
          contractAddress={contractAddress}
          abi={abi}
        />
      )}
    </>
  );
};

export default AllProposals;
