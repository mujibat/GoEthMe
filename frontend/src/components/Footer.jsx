import { SiEthereum } from "react-icons/si";
export default function Footer() {
 return (
  <footer className="bg-green-600 p-4">
   <div className="md:flex md:justify-between items-center">
    <div className="text-black font-bold text-center md:text-left text-2xl mt-2 flex justify-center">
     Built by
     <SiEthereum />
     <a
      className="cursor-pointer underline"
      target="_blank"
      rel="noreferrer"
      href="#"
     >
      web3bridge.eth
     </a>
     <SiEthereum />
    </div>
   </div>
  </footer>
 );
}
