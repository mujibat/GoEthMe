import "./Services.css";
import {
  IoLeafOutline,
  IoFlowerOutline,
  IoArrowForward,
  IoEarthOutline,
  IoBoatOutline,
} from "react-icons/io5";

const Service = () => {
  const backgroundImageUrl =
    "https://res.cloudinary.com/damkols/image/upload/v1699981970/web3bridge/t41sauwtsml3h1fq0prt.png";

  return (
    <section
      className="section service"
      id="service"
      style={{ backgroundImage: `url(${backgroundImageUrl})` }}
    >
      <div className="contain">
        <p className="section-subtitle">
          <img
            src="https://res.cloudinary.com/damkols/image/upload/v1699982436/web3bridge/iz5yi8xlljvkfzvi2tvy.png"
            width="32"
            height="7"
            alt="Wavy line"
          />
          <span>What We Do</span>
        </p>
        <h2 className="h3 section-title">
          We Work Differently to <strong>keep The World Safe</strong>
        </h2>
        <ul className="service-list">
          <li>
            <div className="service-card">
              <div className="card-icon">
                <IoLeafOutline />
              </div>
              <h3 className="h6 card-title">Save Nature</h3>
              <p className="card-text">
                Tempor incididunt ut labores dolore magna suspene
              </p>
              <a href="#" className="btn-link">
                <span>Read More</span>
                <IoArrowForward />
              </a>
            </div>
          </li>
          <li>
            <div className="service-card">
              <div className="card-icon">
                <IoEarthOutline />
              </div>
              <h3 className="h6 card-title">Save Ecology</h3>
              <p className="card-text">
                Tempor incididunt ut labores dolore magna suspene
              </p>
              <a href="#" className="btn-link">
                <span>Read More</span>
                <IoArrowForward />
              </a>
            </div>
          </li>
          <li>
            <div className="service-card">
              <div className="card-icon">
                <IoFlowerOutline />
              </div>
              <h3 className="h6 card-title">Tree Plantation</h3>
              <p className="card-text">
                Tempor incididunt ut labores dolore magna suspene
              </p>
              <a href="#" className="btn-link">
                <span>Read More</span>
                <IoArrowForward />
              </a>
            </div>
          </li>
          <li>
            <div className="service-card">
              <div className="card-icon">
                <IoBoatOutline />
              </div>
              <h3 className="h6 card-title">Clear Ocean</h3>
              <p className="card-text">
                Tempor incididunt ut labores dolore magna suspene
              </p>
              <a href="#" className="btn-link">
                <span className="read">Read More</span>
                <IoArrowForward />
              </a>
            </div>
          </li>
        </ul>
      </div>
    </section>
  );
};

export default Service;
