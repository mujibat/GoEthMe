import { IoHeartOutline } from "react-icons/io5";
import "./CTA.css";

const Cta = () => {
  return (
    <section className="section cta">
      <div className="contain">
        <div className="cta-content">
          <h2 className="h3 section-title">324+ Trusted Global Partners</h2>
          <button className="btn btn-outline">
            <span>Become a Partner</span>
            <IoHeartOutline />
          </button>
        </div>
        <figure className="cta-banner">
          <img
            src="https://res.cloudinary.com/damkols/image/upload/v1699982137/web3bridge/pinxcmkxlrnvql67mxj0.jpg"
            width="520"
            height="228"
            loading="lazy"
            alt="Fox"
            className="img-cover"
          />
        </figure>
      </div>
    </section>
  );
};

export default Cta;
