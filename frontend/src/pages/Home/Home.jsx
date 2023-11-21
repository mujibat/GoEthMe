import React from "react";
import "./Home.css";
import Hero from "../../landing/Hero";
import About from "../../landing/About";
import Cta from "../../landing/CTA";
import Service from "../../landing/Service";
import Donate from "../../landing/Donate";
import Partners from "../../landing/Partners";
// import Service from "../../landing/Service";

const Home = () => {
  return (
    <>
      <Hero />
      <About />
      <Cta />
      <Service />
      <Donate />
      <Partners />
    </>
  );
};

export default Home;
