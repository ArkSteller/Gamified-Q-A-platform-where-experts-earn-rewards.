
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GamifiedQAPlatform {
    address public owner;
    uint256 public questionCount = 0;
    uint256 public rewardPool = 0;

    struct Question {
        uint256 id;
        string content;
        address asker;
        bool answered;
        uint256 reward;
    }

    struct Answer {
        uint256 questionId;
        string content;
        address responder;
        uint256 upvotes;
    }

    mapping(uint256 => Question) public questions;
    mapping(uint256 => Answer[]) public answers;

    event QuestionAsked(uint256 questionId, string content, address asker);
    event AnswerSubmitted(uint256 questionId, string content, address responder);
    event Upvoted(uint256 questionId, address responder);
    event RewardClaimed(address expert, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function askQuestion(string memory _content) public payable {
        require(msg.value > 0, "Reward must be greater than 0");
        questionCount++;
        questions[questionCount] = Question(questionCount, _content, msg.sender, false, msg.value);
        rewardPool += msg.value;
        emit QuestionAsked(questionCount, _content, msg.sender);
    }

    function submitAnswer(uint256 _questionId, string memory _content) public {
        require(questions[_questionId].id == _questionId, "Question does not exist");
        answers[_questionId].push(Answer(_questionId, _content, msg.sender, 0));
        emit AnswerSubmitted(_questionId, _content, msg.sender);
    }

    function upvoteAnswer(uint256 _questionId, uint256 _answerIndex) public {
        Answer storage answer = answers[_questionId][_answerIndex];
        answer.upvotes++;
        emit Upvoted(_questionId, answer.responder);
    }

    function claimReward(uint256 _questionId, uint256 _answerIndex) public {
        Answer storage answer = answers[_questionId][_answerIndex];
        Question storage question = questions[_questionId];

        require(answer.responder == msg.sender, "Only the answerer can claim reward");
        require(question.answered == false, "Reward already claimed");
        require(answer.upvotes >= 5, "Minimum upvotes not reached");

        question.answered = true;
        payable(msg.sender).transfer(question.reward);
        rewardPool -= question.reward;

        emit RewardClaimed(msg.sender, question.reward);
    }
}
