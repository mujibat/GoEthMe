import {
  MediaRenderer,
  useContract,
  useStorage,
  useStorageUpload,
} from "@thirdweb-dev/react";
import React, { useCallback, useState } from "react";
import { toast } from "react-hot-toast";
import { useContractWrite } from "@thirdweb-dev/react";
import { ethers } from "ethers";
import { useDropzone } from "react-dropzone";

const CreateProposal = ({ showModal, closeModal, contractAddress, abi }) => {
  const { contract } = useContract(contractAddress, abi);
  const [proposalImage, setProposalImage] = useState("");
  const [imageSet, setImageSet] = useState(false);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [targetAmount, setTargetAmount] = useState(0);
  const [duration, setDuration] = useState(0);
  const { mutateAsync, isLoading, error } = useContractWrite(
    contract,
    "createGofundme"
  );

  const { mutateAsync: upload } = useStorageUpload();
  const onDrop = useCallback(
    async (acceptedFiles) => {
      try {
        toast.loading("Uploading image...", {
          id: 1,
        });

        const uris = await upload({ data: acceptedFiles });
        const file = uris[0];

        setProposalImage(file);
        setImageSet(true);

        toast.success("Image uploaded successfully!", {
          id: 1,
        });
      } catch (error) {
        toast.error("Error uploading image.", {
          id: 1,
        });
        console.error(error);
      }
    },

    [upload]
  );
  const { getRootProps, getInputProps } = useDropzone({ onDrop });

  const handleInput = (e) => {
    const value = e.target.value;

    if (value < 0) {
      toast.error("Amount must be greater than 0");
      return;
    }

    setTargetAmount(e.target.value);
  };

  return (
    <div
      className={`fixed top-0 left-0 h-screen w-screen bg-opacity-50 bg-black flex justify-center z-50 items-center ${
        showModal ? "visible" : "invisible"
      }`}
    >
      <div className="bg-white p-4 rounded-lg max-w-xl w-full">
        {/* Heading */}
        <h2 className="text-center text-2xl font-semibold mb-4 border-b-2 border-green-500 pb-2">
          Create New Proposal
        </h2>
        <div className="flex flex-col md:flex-row justify-center items-center mb-4 md:space-x-4">
          {/* Image Upload Option */}
          <label
            className="relative mb-4 md:mb-0 text-center"
            {...getRootProps()}
            onClick={(e) => e.stopPropagation()}
          >
            <input
              type="file"
              accept="image/*"
              className="hidden"
              {...getInputProps()}
            />
            <div className="w-24 h-24 md:w-36 md:h-36 border-2 border-dashed border-gray-400 rounded-lg flex justify-center items-center cursor-pointer">
              {imageSet ? (
                <MediaRenderer src={proposalImage} />
              ) : (
                <p>Upload Image</p>
              )}
            </div>
          </label>
          <div className="md:ml-4 w-full">
            {/* Title */}
            <label htmlFor="title" className="block mb-1 font-semibold">
              Title
            </label>
            <input
              type="text"
              id="title"
              className="w-full px-4 py-2 rounded-lg border border-gray-300 mb-2 md:mb-4"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
            {/* Description */}
            <label htmlFor="description" className="block mb-1 font-semibold">
              Description
            </label>
            <textarea
              id="description"
              rows="3"
              className="w-full px-4 py-2 rounded-lg border border-gray-300 mb-2 md:mb-4"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
            {/* Target Amount */}
            <label htmlFor="targetAmount" className="block mb-1 font-semibold">
              Target Amount
            </label>
            <input
              type="number"
              id="targetAmount"
              className="w-full px-4 py-2 rounded-lg border border-gray-300 mb-2 md:mb-4"
              value={targetAmount}
              onChange={handleInput}
            />
            {/* Duration */}
            <label htmlFor="duration" className="block mb-1 font-semibold">
              Duration
            </label>
            <div className="relative">
              <select
                id="duration"
                className="py-3 px-4 pe-9 block w-full bg-gray-100 border-transparent rounded-lg text-sm focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none dark:bg-gray-700 dark:border-transparent dark:text-gray-400 dark:focus:ring-gray-600"
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
              >
                <option value="">Select Duration</option>
                <option value="1">1 day</option>
                <option value="2">2 days</option>
                <option value="3">3 days</option>
                <option value="4">4 days</option>
                <option value="5">5 days</option>
                <option value="6">6 days</option>
                <option value="7">7 days</option>
                <option value="7">8 days</option>
                <option value="7">9 days</option>
                <option value="7">10 days</option>
                <option value="7">15 days</option>
                <option value="7">20 days</option>
                <option value="7">25 days</option>
                <option value="7">30 days</option>
              </select>
            </div>
          </div>
        </div>
        <div className="flex justify-end">
          {/* Cancel Button */}
          <button
            className="bg-gray-400 text-white rounded-lg px-4 py-2 mr-2"
            onClick={closeModal}
          >
            Cancel
          </button>
          {/* Create Button */}
          <button
            className="bg-green-500 hover:bg-green-600 text-white rounded-lg px-4 py-2"
            onClick={async () => {
              toast.loading("Creating campaign...", {
                id: 2,
              });
              try {
                const currentTimeInSeconds = new Date().getTime() / 1000;
                const durationInSeconds = Number(duration) * 24 * 60 * 60;
                await mutateAsync({
                  args: [
                    title.toString(),
                    description.toString(),
                    ethers.utils.parseEther(targetAmount.toString()),
                    durationInSeconds,
                    proposalImage,
                  ],
                });
                toast.success("Campaign created successfully!", {
                  id: 2,
                });
              } catch (error) {
                toast.error("Error creating campaign.", {
                  id: 2,
                });
                console.error(error);
              }
              closeModal();
            }}
          >
            Create
          </button>
        </div>
      </div>
    </div>
  );
};

export default CreateProposal;
