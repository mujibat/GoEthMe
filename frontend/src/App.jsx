import React, { useEffect } from "react";
import Navbar from "./components/Navbar";
import { useAddress } from "@thirdweb-dev/react";
import Sidebar from "./components/Sidebar";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import "./index.css";
import Details from "./components/Details.jsx";
import ProposalDetails from "./components/ProposalDetails.jsx";
import Campaigns from "./pages/Campaigns.jsx";
import Home from "./pages/Home/Home.jsx";
import Proposals from "./pages/Proposals.jsx";
import daoABi from "./abis/daoAbi.json";

export default function App() {
  const address = useAddress();
  const desiredChainId = "0xAA36A7";

  //84531
  //0x14a33

  const connectToSepoliaTestnet = async () => {
    if (address) {
      if (window.ethereum) {
        const chainId = await window.ethereum.request({
          method: "eth_chainId",
        });

        // Check if connected to a different network (not Sepolia testnet)
        if (chainId !== desiredChainId) {
          // ChainId of Sepolia testnet is '0xAA36A7'
          try {
            await window.ethereum.request({
              method: "wallet_switchEthereumChain",
              params: [{ chainId: desiredChainId }],
            });
          } catch (error) {
            // Handle error
            console.log("Error while switching to Sepolia testnet:", error);
          }
        }
      } else {
        // Handle case where window.ethereum is not available
        console.log("Metamask not available");
      }
    }
  };
  useEffect(() => {
    connectToSepoliaTestnet();
  }, [daoABi.address]);

  return (
    <BrowserRouter>
      <>
        {/* <Routes>
          <Route path="/" element={<Home />} />
        </Routes> */}
        <div className="relative sm:-8 bg-[#F5F5F5] dark:bg-[#13131a] min-h-screen flex flex-row">
          <div className="hidden sm:flex relative">
            <Routes>
              <Route path="/:any/*" element={<Sidebar />} />
            </Routes>
          </div>
          <div className="flex-1">
            {" "}
            {/* Display Navbar only when not on the landing page */}
            <Routes>
              <Route path="/:any/*" element={<Navbar />} />
            </Routes>
            {/* <Header /> */}
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/details" element={<Campaigns />} />
              <Route path="/details/:id/*" element={<Details />} />
              <Route path="/proposals" element={<Proposals />} />
              <Route
                path="/proposal-details/:id/*"
                element={<ProposalDetails />}
              />
            </Routes>
          </div>
        </div>
      </>
    </BrowserRouter>
  );
}
