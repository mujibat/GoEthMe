import { IoHeartOutline } from "react-icons/io5";
import "./Donate.css";
import { Link } from "react-router-dom";

const Donate = () => {
  const donateCards = [
    {
      imageSrc:
        "https://res.cloudinary.com/damkols/image/upload/v1700325644/web3bridge/ud90xagvge0yym7hfnw1.png",
      title: "Raise Hand To Save Animals",
    },
    {
      imageSrc:
        "https://res.cloudinary.com/damkols/image/upload/v1700091915/web3bridge/ghskcher8qqx6pdn1i3i.jpg",
      title: "Raise Hands To Clean up the Ocean",
    },
    {
      imageSrc:
        "https://res.cloudinary.com/damkols/image/upload/v1700092019/web3bridge/sj4xv46nlcgqtn6doc9a.jpg",
      title: "Raise Hands To plant more Trees",
    },
    {
      imageSrc:
        "https://res.cloudinary.com/damkols/image/upload/v1700091688/web3bridge/rowvga3x1h98xhj7slqi.jpg",
      title: "Raise Hands To save Ecology",
    },
  ];

  return (
    <section className="section donate" id="donate">
      <div className="contain">
        <ul className="donate-list">
          {donateCards.map((card, index) => (
            <li key={index}>
              <div className="donate-card">
                <figure className="card-banner">
                  <img
                    src={card.imageSrc}
                    width="520"
                    height="325"
                    loading="lazy"
                    alt="Elephant"
                    className="img-cover"
                  />
                </figure>
                <div className="card-content">
                  <h3 className="card-title">{card.title}</h3>
                  <Link to="/details">
                    <button className="btn btn-secondary">
                      <span>Donate to Cause</span>
                      <IoHeartOutline />
                    </button>
                  </Link>
                </div>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
};

export default Donate;
