import { useContract, useContractWrite } from "@thirdweb-dev/react";
import { useState } from "react";
import { Toaster, toast } from "react-hot-toast";
import ConfettiExplosion from "react-confetti-explosion";
import { useNavigate } from "react-router-dom";
import { shortenAccount } from "../utils";
function VoteModal({
  open,
  onClose,
  campaignTitle,
  owner,
  campaignId,
  contractAddress,
  abi,
}) {
  const { contract } = useContract(contractAddress, abi);
  const navigate = useNavigate();
  const {
    mutateAsync: voteCall,
    isLoading,
    error,
  } = useContractWrite(contract, "vote");
  const [confettiCelebration, setConfettiCelebration] = useState(false);

  // contract.events.listenToAllEvents((event) => {
  //   console.log(event.Vote); // the name of the emitted event
  //   console.log(event._id, event.member); // event payload
  // });

  if (!open) return null;

  return (
    <>
      <Toaster />
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-6">
        <div className="bg-white rounded-lg p-10 max-w-xl">
          <h3 className="text-lg font-bold text-center mb-4 mt-0 pt-0">
            {campaignTitle}
          </h3>
          <p className="text-sm text-pink-500 text-center mb-4">
            Created by {owner}
          </p>
          <p className="text-sm text-black-500 text-center mb-4">
            Vote for this Proposal
          </p>
          <div className="flex justify-center items-center gap-3 mt-10">
            <button
              className="py-3 px-4 inline-flex items-center gap-x-2 text-sm font-semibold rounded-lg border border-transparent bg-green-500 text-white hover:bg-green-600 disabled:opacity-50 disabled:pointer-events-none dark:focus:outline-none dark:focus:ring-1 dark:focus:ring-gray-600"
              onClick={async () => {
                toast.loading("Voting for proposal...", {
                  id: 2,
                });
                try {
                  await voteCall({
                    args: [campaignId, 0],
                  });
                  toast.success("Voted Succesfully", {
                    id: 2,
                  });
                  setConfettiCelebration(true);
                  onClose();
                  setTimeout(() => {
                    // Code to run
                    navigate("/proposals");
                  }, 5000);
                } catch (error) {
                  toast.error("You are ineligible to Vote.", {
                    id: 2,
                  });
                  console.error(error);
                }
              }}
            >
              Yes
            </button>
            <button
              className="py-3 px-4 inline-flex items-center gap-x-2 text-sm font-semibold rounded-lg border border-transparent bg-yellow-500 text-white hover:bg-yellow-600 disabled:opacity-50 disabled:pointer-events-none dark:focus:outline-none dark:focus:ring-1 dark:focus:ring-gray-600"
              onClick={async () => {
                toast.loading("Voting for proposal...", {
                  id: 2,
                });
                try {
                  await voteCall({
                    args: [campaignId, 1],
                  });
                  toast.success("Voted Succesfully", {
                    id: 2,
                  });
                  setConfettiCelebration(true);
                  onClose();
                  setTimeout(() => {
                    // Code to run
                    navigate("/proposals");
                  }, 5000);
                } catch (error) {
                  toast.error("You are ineligible to Vote.", {
                    id: 2,
                  });
                  console.error(error);
                }
              }}
            >
              No
            </button>
          </div>
          <div className="flex justify-around pt-5">
            <button
              className="bg-red-500 mt-5 text-white font-xl rounded-lg p-3 px-4"
              onClick={onClose}
            >
              Cancel
            </button>
            {confettiCelebration && <ConfettiExplosion />}
          </div>
        </div>
      </div>
    </>
  );
}

export default VoteModal;
