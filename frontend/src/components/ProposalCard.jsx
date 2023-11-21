import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ethers } from "ethers";

const ProposalCard = ({ data }) => {
  const navigate = useNavigate();
  const url = data.image;
  const raisedPercent = data.raised / data.target;
  const detailsParams = data.id + data.title + data.owner;
  const hash = ethers.utils
    .keccak256(ethers.utils.toUtf8Bytes(detailsParams))
    .split("0x")[1]
    .slice(0, 8);

  const gatewayUrl = `https://ipfs.io/ipfs/${url.split("//")[1]}`;
  const dateInSeconds = Math.floor(new Date(data.endAt).getTime() / 1000);

  return (
    <div className="w-[288px] md:w-full rounded-[15px] dark:bg-[#1c1c24] bg-white">
      <img
        className="w-full rounded-t-xl h-[200px] object-cover rounded-[15px]"
        src={gatewayUrl}
        alt="Image Description"
      />
      <div className="p-4 md:p-5">
        <h3 className="text-lg font-bold text-gray-800 dark:text-white">
          {data.title.length > 17
            ? data.title.slice(0, 17) + "..."
            : data.title}
        </h3>
        <p className="mt-1 text-gray-500 dark:text-gray-400">
          {data.description.length > 40
            ? data.description.slice(0, 40) + "..."
            : data.description}
        </p>
        <div
          className="cursor-pointer mt-2 py-3 px-6 inline-flex justify-center items-center gap-x-2 text-sm font-semibold rounded-lg border border-transparent bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:pointer-events-none dark:focus:outline-none dark:focus:ring-1 dark:focus:ring-gray-600"
          onClick={() =>
            navigate(`/proposal-details/${hash}`, {
              state: {
                campaignId: data.id,
                title: data.title,
                description: data.description,
                image: data.image,
                target: data.target,
                raised: data.raised,
                endAt: dateInSeconds,
                status: data.status,
                owner: data.owner,
              },
            })
          }
        >
          Vote
        </div>
      </div>
    </div>
  );
};

export default ProposalCard;
