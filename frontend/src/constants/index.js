import {
  createCampaign,
  dashboard,
  logout,
  payment,
  profile,
  withdraw,
} from "../assets";

export const navlinks = [
  {
    name: "dashboard",
    imgUrl: dashboard,
    link: "/details",
  },
  {
    name: "proposals",
    imgUrl: createCampaign,
    link: "/proposals",
  },
  //  {
  //   name: "payment",
  //   imgUrl: payment,
  //   link: "/",
  //   disabled: true,
  //  },
  //  {
  //   name: "withdraw",
  //   imgUrl: withdraw,
  //   link: "/",
  //   disabled: true,
  //  },
  // {
  //   name: "profile",
  //   imgUrl: profile,
  //   link: "/profile",
  // },
  // {
  //   name: "logout",
  //   imgUrl: logout,
  //   link: "/",
  //   disabled: true,
  // },
];
