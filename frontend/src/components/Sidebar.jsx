import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";

import { logo, sun } from "../assets";
import { navlinks } from "../constants";
import useDarkMode from "../hooks/useDarkMode";
import { BiSolidMoon } from "react-icons/bi";

export const Icon = ({
  styles,
  name,
  imgUrl,
  isActive,
  disabled,
  handleClick,
}) => (
  <div
    className={`w-[48px] h-[48px] rounded-[10px] ${
      isActive && isActive === name && "bg-white dark:bg-[#2c2f32]"
    } flex justify-center items-center ${
      !disabled && "cursor-pointer"
    } ${styles}`}
    onClick={handleClick}
  >
    {!isActive ? (
      <img src={imgUrl} alt="fund_logo" className="w-1/2 h-1/2" />
    ) : (
      <img
        src={imgUrl}
        alt="fund_logo"
        className={`w-1/2 h-1/2 ${isActive !== name && "grayscale"}`}
      />
    )}
  </div>
);

const Sidebar = () => {
  const [theme, toggleTheme] = useDarkMode();

  if (theme === "light") {
    document.documentElement.classList.remove("dark");
  } else {
    document.documentElement.classList.add("dark");
  }
  const navigate = useNavigate();
  const [isActive, setIsActive] = useState("dashboard");

  return (
    <div className="flex p-4 mr-10 justify-between items-center flex-col sticky top-5 h-[93vh] max-sm:w-full max-w-[1400px] mx-auto">
      <Link to="/">
        <Icon
          styles="w-[52px] h-[52px] bg-white dark:bg-[#2c2f32]"
          imgUrl={logo}
        />
      </Link>

      <div className="bg-white dark:bg-[#1c1c24] flex-1 flex flex-col justify-between items-center rounded-[20px] w-[76px] py-4 mt-12">
        <div className="flex flex-col justify-center items-center gap-3">
          {navlinks.map((link) => (
            <Icon
              key={link.name}
              {...link}
              isActive={isActive}
              handleClick={() => {
                if (!link.disabled) {
                  setIsActive(link.name);
                  navigate(link.link);
                }
              }}
            />
          ))}
        </div>

        <button onClick={toggleTheme} className="text-black dark:text-white">
          {theme === "light" ? (
            <BiSolidMoon fontSize={30} />
          ) : (
            <Icon
              styles="dark:bg-white bg-[#1c1c24] shadow-secondary"
              imgUrl={sun}
            />
          )}
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
