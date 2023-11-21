import {
  useAddress,
  useContract,
  useContractRead,
  useContractWrite,
} from "@thirdweb-dev/react";
import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { toast } from "react-hot-toast";
import VoteModal from "./VoteModal";
import CustomButton from "./CustomButton";
import daoABi from "../abis/daoAbi.json";
import { MutatingDots } from "react-loader-spinner";

const ProposalDetails = () => {
  const navigate = useNavigate();
  const contractAddress = daoABi.address;
  const abi = daoABi.abi;
  const { contract } = useContract(contractAddress, abi);

  const { state } = useLocation();
  const {
    campaignId,
    owner,
    title,
    description,
    image,
    target,
    raised,
    status,
    endAt,
  } = state;
  const gatewayUrl = `https://ipfs.io/ipfs/${image.split("//")[1]}`;
  const address = useAddress();
  const [voteModal, setVoteModal] = useState(false);

  const {
    data: voteTime,
    isLoading,
    isError,
  } = useContractRead(contract, "getVoteTime", [campaignId]);

  const {
    data: yayVotes,
    // isLoading,
    // isError,
  } = useContractRead(contract, "getYayVotes", [campaignId]);

  const {
    data: nayVotes,
    // isLoading,
    // isError,
  } = useContractRead(contract, "getNayVotes", [campaignId]);

  const date = new Date(voteTime * 1000).toLocaleString();

  const { mutateAsync: approveCall } = useContractWrite(
    contract,
    "approveProposal"
  );

  async function voteForProposal() {
    if (!address) {
      toast.error("Connect Wallet to Vote for Proposal");
    } else {
      setVoteModal(true);
    }
  }

  return (
    <>
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
      {isError && <p>Error Loading Campaigns</p>}
      {!isLoading && !isError && (
        <div className="flex flex-col justify-center items-center gap-3 p-4 md:p-5">
          <div className="flex justify-center items-center w-2/4">
            <img
              className="w-3/4 h-1/4 rounded-t-xl"
              src={gatewayUrl}
              alt="Image Description"
            />
          </div>
          <div className="flex flex-col justify-center items-center gap-3 p-4 md:p-5">
            <h3 className="text-lg font-bold text-gray-800 dark:text-white">
              {title}
            </h3>
            <p className="mt-1 text-gray-500 dark:text-gray-400">
              {description}
            </p>

            <button
              className="bg-green-300 mt-5 text-black p-3 rounded-lg font-semibold hover:bg-purple-900 hover:text-white"
              onClick={voteForProposal}
            >
              Cast your Vote
            </button>
            <div className="flex gap-5">
              <p className="mt-1 text-xl bg-[#1dc0b2] rounded-lg p-5 text-gray-900 dark:text-gray-400">
                Yes: {Number(yayVotes)}
              </p>
              <p className="mt-1 text-xl bg-[#1dc0b2] rounded-lg p-5 text-gray-900 dark:text-gray-400">
                No: {Number(nayVotes)}
              </p>
            </div>
            <p className="mt-1 text-xl text-gray-900 dark:text-gray-400">
              Voting ends: <span className="">{date}</span>
            </p>
            <VoteModal
              open={voteModal}
              onClose={() => setVoteModal(false)}
              campaignTitle={title}
              owner={owner}
              campaignId={campaignId}
              contractAddress={contractAddress}
              abi={abi}
            />
            <div className="mt-5">
              {address ? (
                <CustomButton
                  btnType="button"
                  title="Approve Proposal"
                  styles={address ? "bg-[#1dc071]" : "bg-[#8c6dfd]"}
                  handleClick={async () => {
                    toast.loading("Approving Proposal...", {
                      id: 2,
                    });
                    try {
                      await approveCall({
                        args: [campaignId],
                      });
                      toast.success("Proposal Approved successfully!", {
                        id: 2,
                      });
                      navigate("/details");
                    } catch (error) {
                      toast.error("Error approving proposal.", {
                        id: 2,
                      });
                      console.error(error);
                    }
                  }}
                />
              ) : (
                <p>Not a DAO member</p>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ProposalDetails;
