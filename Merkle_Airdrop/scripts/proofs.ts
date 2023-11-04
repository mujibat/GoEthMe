import MerkleTree from "merkletreejs";
import { keccak256 } from "ethers/lib/utils";
import csv from "csv-parser";
import * as fs from "fs";
import { utils } from "ethers";
import path from "path";
// import { Data } from "./hashData";

function main() {
  // create web3 instance (no provider needed)

  let root;

  ///files for each ardrop
  // import distribution from this file
  const filename = path.join(__dirname, "gen_files/AirdropData.csv");

  // what file should we write the merkle proofs too?
  const output_file = path.join(__dirname, "gen_files/merkle_tree.json");

  //file that has the user claim list
  const userclaimFile = path.join(__dirname, "gen_files/claimer2.json");

  //contract of items being sent out
  const airdropContract = "";

  // used to store one leaf for each line in the distribution file
  const token_dist: any[] = [];

  // used for tracking user_id of each leaf so we can write to proofs file accordingly
  const user_dist_list: any[][] = [];
  fs.createReadStream(filename)
    .pipe(csv())
    .on("data", (row) => {
      const user_dist = [row["user_address"], row["amount"]]; // create record to track user_id of leaves
      const leaf_hash = utils.solidityKeccak256(
        ["address", "uint256"],
        [row["user_address"], row["amount"]]
      ); // encode base data like solidity abi.encode
      user_dist_list.push(user_dist); // add record to index tracker
      token_dist.push(leaf_hash); // add leaf hash to distribution
    })
    .on("end", () => {
      // create merkle tree from token distribution
      const merkle_tree = new MerkleTree(token_dist, keccak256, {
        sortPairs: true,
      });
      // get root of our tree
      root = merkle_tree.getHexRoot();
      // create proof file
      write_leaves(merkle_tree, user_dist_list, token_dist, root);
    });

  // write leaves & proofs to json file
  function write_leaves(
    merkle_tree: MerkleTree,
    user_dist_list: string | any[],
    token_dist: any[],
    root: string
  ) {
    console.log("Begin writing leaves to file...");
    let full_dist: { [key: string]: any } = {};
    let full_user_claim: { [key: string]: any } = {};
    let line: number;

    for (line = 0; line < user_dist_list.length; line++) {
      // generate leaf hash from raw data
      const leaf = token_dist[line];

      // create dist object
      const user_dist = {
        leaf: leaf,
        proof: merkle_tree.getHexProof(leaf),
      };
      // add record to our distribution
      full_dist[user_dist_list[line][0]] = user_dist;
    }

    fs.writeFile(output_file, JSON.stringify(full_dist, null, 4), (err) => {
      if (err) {
        console.error(err);
        return;
      }

      let dropObjs = {
        dropDetails: {
          contractAddress: airdropContract,
          merkleroot: root,
        },
      };

      for (line = 0; line < user_dist_list.length; line++) {
        const other = user_dist_list[line];
        // console.log(gotchi_dist_list[line])
        const user_claim = {
          address: other[0],
          itemID: other[1],
          amount: other[2],
        };
        full_user_claim[user_dist_list[line][0]] = user_claim;
      }
      let newObj = Object.assign(full_user_claim, dropObjs);
      //append to airdrop list to have comprehensive overview
      fs.writeFile(userclaimFile, JSON.stringify(newObj, null, 4), (err) => {
        if (err) {
          console.error(err);
          return;
        }
      });
      console.log(output_file, "has been written with a root hash of:\n", root);
    });

    // return root;
  }
}
main();
