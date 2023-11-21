import { IoHeartOutline } from "react-icons/io5";
import "./Hero.css";
import Features from "../Features";
import { Link } from "react-router-dom";

const Hero1 = () => {
  return (
    <section className="hero" id="home">
      <div className="contain">
        <p className="section-subtitle">
          <img
            src="https://res.cloudinary.com/damkols/image/upload/v1699982461/web3bridge/oic7wa9y1hjjajsog0av.png"
            width="32"
            height="7"
            alt="Wavy line"
          />
          <span>Welcome to Earth-Sustain</span>
        </p>
        <h2 className="h1 hero-title">
          Contribute to Saving <br />
          <strong>The Planet</strong>
        </h2>
        <p className="hero-text">
          Sit amet consectetur adipiscing elit, sed do eiusmod tempor incididunt
          ut labore et dolore magna aliqua suspendisse ultrices gravida.
        </p>
        <Link to="/details">
          <button className="btn btn-primary">
            <span>Go to dapp</span>
            <IoHeartOutline className="ion-icon" />
          </button>
        </Link>
      </div>
      <Features />
    </section>
  );
};

export default Hero1;
