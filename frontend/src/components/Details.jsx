import {
  useAddress,
  useContract,
  useContractRead,
  useContractWrite,
} from "@thirdweb-dev/react";
import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { Toaster, toast } from "react-hot-toast";
import { PiMaskSadLight } from "react-icons/pi";
import Contribute from "./ContributionModal";
import { ethers } from "ethers";
import { v4 as uuidv4 } from "uuid";
import { shortenAccount } from "../utils";
import goEth from "../abis/goEth.json";
import { MutatingDots } from "react-loader-spinner";

export default function Details() {
  const navigate = useNavigate();
  const contractAddress = goEth.address;
  const abi = goEth.abi;
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
    startAt,
  } = state;
  const date = new Date(endAt * 1000).toLocaleDateString();
  const gatewayUrl = `https://ipfs.io/ipfs/${image.split("//")[1]}`;
  const address = useAddress();
  const [contribution, setContribution] = useState([]);
  const [contributionModal, setContributionModal] = useState(false);
  const {
    data: contributors,
    isLoading,
    isError,
  } = useContractRead(contract, "getContributors", [campaignId]);

  const date1 = new Date(startAt * 1000).toLocaleString();
  const date2 = new Date(endAt * 1000).toLocaleString();

  const calculateTimeLeft = () => {
    // const now = new Date().getTime();
    const difference = endAt * 1000 - startAt * 1000;

    if (difference > 0) {
      const days = Math.floor(difference / (1000 * 60 * 60 * 24));
      const hours = Math.floor(
        (difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
      );
      const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((difference % (1000 * 60)) / 1000);

      return {
        days,
        hours,
        minutes,
        seconds,
      };
    } else {
      // Target date has passed
      return null;
    }
  };

  const [timeLeft, setTimeLeft] = useState(calculateTimeLeft());

  useEffect(() => {
    const timer = setInterval(() => {
      const timeLeft = calculateTimeLeft();
      if (timeLeft !== null) {
        setTimeLeft(timeLeft);
      } else {
        clearInterval(timer);
      }
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  async function getAllContributions() {
    if (contributors) {
      const filter = contributors.map((data) => {
        return {
          amount: ethers.utils.formatEther(data.balance),
          contributor: data.contributor.toString(),
          contriDate: new Date(data.time * 1000).toLocaleDateString(),
        };
      });
      setContribution(filter);
    }
  }
  const { mutateAsync: getContributedFundsCall } = useContractWrite(
    contract,
    "getContributedFunds"
  );

  useEffect(() => {
    getAllContributions();
  }, [contributors]);

  async function contributeToCampaign() {
    if (!address) {
      toast.error("Connect Wallet to Contribute to a campaign");
    } else {
      setContributionModal(true);
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
        <>
          <Toaster />
          <div className="my-10 text-3xl font-bold text-center mb-12 text-[#1c1c24] dark:text-white">
            Details Page
          </div>
          <div className="flex flex-wrap w-5/6  mx-auto p-0 md:pl-20">
            <div className="md:w-1/2 w-full">
              <img
                src={gatewayUrl}
                className="md:w-4/5 rounded-2xl min-w-full md:min-w-0"
              />
            </div>

            <div className="flex flex-col md:w-80 w-full justify-between text-center md:text-left mt-10 md:m-0 text-[#1c1c24] dark:text-white">
              <div className="md:h-1/2 h-2/3 border-b-8 border-green-400 flex flex-col justify-around">
                <h2 className="text-3xl font-bold mb-5">
                  {title}
                  {address == owner && <></>}
                </h2>

                <p className="mb-4 text-xl pb-5">{description}</p>
              </div>
              <div className="flex flex-col justify-around md:h-1/2 text-xl font-semibold mt-8">
                <div>
                  Created By :{" "}
                  <a
                    className="underline italic font-semibold"
                    href={`https://sepolia.etherscan.io/address/${owner}`}
                    target="_blank"
                    rel="noreferrer"
                  >
                    {shortenAccount(owner)}
                  </a>
                </div>
                <div>Target : {target} ETH</div>
                <div>Raised {raised} ETH</div>
                <div>Start date : {date1}</div>
                <div>Ends on : {date2}</div>
                {/* <div>
                  {timeLeft !== null ? (
                    <p className="text-xs mt-2">
                      Time left: {timeLeft.days} days, {timeLeft.hours} hours,{" "}
                    </p>
                  ) : (
                    <p>Target date has passed</p>
                  )}
                </div> */}
              </div>
            </div>
          </div>
          <div className="my-14 flex md:justify-end justify-center md:w-4/5 w-full">
            {address == owner && (
              <button
                className="bg-white text-red-600 hover:bg-red-500 hover:text-white  p-3 mx-5 rounded-lg font-semibold"
                onClick={async () => {
                  toast.loading("Claiming Contribution", {
                    id: 2,
                  });
                  try {
                    await getContributedFundsCall({
                      args: [campaignId],
                    });
                    toast.success("Claimed Succesfully", {
                      id: 2,
                    });

                    setTimeout(() => {
                      navigate("/details");
                    }, 5000);
                  } catch (error) {
                    toast.error("Error Claiming campaign.", {
                      id: 2,
                    });
                    console.error(error);
                  }
                }}
              >
                Claim Contribution
              </button>
            )}
            <button
              className="bg-green-300 text-black p-3 rounded-lg font-semibold hover:bg-purple-900 hover:text-white"
              onClick={contributeToCampaign}
            >
              Contribute to this Campaign
            </button>
            <Contribute
              open={contributionModal}
              onClose={() => setContributionModal(false)}
              campaignTitle={title}
              owner={owner}
              campaignId={campaignId}
              contractAddress={contractAddress}
              abi={abi}
            />
          </div>
          {contribution.length > 0 && (
            <div className="overflow-x-auto sm:overflow-x-visible w-4/5 mx-auto mt-20">
              <table className="w-full md:text-sm text-left text-gray-500 text-xs">
                <thead className="text-xs text-white uppercase bg-gray-800">
                  <tr>
                    <th scope="col" className="md:px-6 px-2 py-3">
                      Wallet Address
                    </th>
                    <th scope="col" className="md:px-6 px-2 py-3">
                      Amount
                    </th>
                    <th scope="col" className="md:px-6 px-2 py-3">
                      Date
                    </th>
                  </tr>
                </thead>
                <tbody className="max-h-96 h-10 overflow-y-auto">
                  {contribution.map((contri) => (
                    <tr key={uuidv4()} className="">
                      <td className="md:px-6 px-2 py-3">
                        {contri.contributor}
                      </td>
                      <td className="md:pl-7 px-2 py-3">{contri.amount} ETH</td>
                      <td className="md:px-6 px-2 py-3">{contri.contriDate}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
          {contribution.length == 0 && (
            <div className="my-10 text-center text-green-500 text-3xl font-bold flex justify-center">
              <PiMaskSadLight /> No contributions made yet <PiMaskSadLight />
            </div>
          )}
        </>
      )}
    </>
  );
}
