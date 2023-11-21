import React from "react";

function SuccessModal({ onClose }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg p-6 max-w-sm">
        <h3 className="text-lg font-bold text-center mb-4">
          Contribution Successful!
        </h3>
        <p className="text-sm text-green-500 text-center mb-4">
          Thank you for contributing to the campaign.
        </p>
        <button
          className="bg-purple-500 text-white font-xl rounded-lg p-3 px-4"
          onClick={onClose}
        >
          Close
        </button>
      </div>
    </div>
  );
}

export default SuccessModal;
