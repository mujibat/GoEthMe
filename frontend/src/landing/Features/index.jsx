import "./Features.css";
import {
  IoShieldCheckmarkOutline,
  IoWaterOutline,
  IoLeafOutline,
  IoSnowOutline,
} from "react-icons/io5";

const Features = () => {
  return (
    <section className="section features">
      <div className="contain">
        <ul className="features-list">
          <li className="features-item">
            <div className="item-icon">
              <IoShieldCheckmarkOutline />
              {/* <ion-icon name="shield-checkmark-outline"></ion-icon> */}
            </div>
            <div>
              <h3 className="h5 item-title">Safe Planet</h3>
              <p className="item-text">
                Sit amet consecte adiscine eiusm temor ultrices.
              </p>
            </div>
          </li>
          <li className="features-item">
            <div className="item-icon">
              <IoWaterOutline />
              {/* <ion-icon name="water-outline"></ion-icon> */}
            </div>
            <div>
              <h3 className="h5 item-title">Clean Water</h3>
              <p className="item-text">
                Sit amet consecte adiscine eiusm temor ultrices.
              </p>
            </div>
          </li>
          <li className="features-item">
            <div className="item-icon">
              <IoLeafOutline />
              {/* <ion-icon name="leaf-outline"></ion-icon> */}
            </div>
            <div>
              <h3 className="h5 item-title">Preserve Ecology</h3>
              <p className="item-text">
                Sit amet consecte adiscine eiusm temor ultrices.
              </p>
            </div>
          </li>
          <li className="features-item">
            <div className="item-icon">
              <IoSnowOutline />
              {/* <ion-icon name="snow-outline"></ion-icon> */}
            </div>
            <div>
              <h3 className="h5 item-title">Safe Environment</h3>
              <p className="item-text">
                Sit amet consecte adiscine eiusm temor ultrices.
              </p>
            </div>
          </li>
        </ul>
      </div>
    </section>
  );
};

export default Features;
