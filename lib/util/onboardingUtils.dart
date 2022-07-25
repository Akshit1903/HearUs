class OnboardingContent {
  String message;
  String img;
  String backImg;

  OnboardingContent({this.img, this.message, this.backImg});
}

class OnBoardingUtil {
  static List<OnboardingContent> getOnboarding() {
    return [
      OnboardingContent(
          img: "Intro_1.png",
          message: "Talk to empathetic listeners for free",
          backImg: "Backintro_1.png"),
      OnboardingContent(
          img: "Intro_2.png",
          message:
              "Need more help? \nConsult online with our professional psychologists",
          backImg: "Backintro_2.png"),
    ];
  }
}

class MentorQuestionsContent {
  String question;

  MentorQuestionsContent({this.question});
}

class MentorQuestionsContentUtil {
  static List<MentorQuestionsContent> mentorQuestions() {
    return [
      MentorQuestionsContent(
          question: 'How do u rate your current performance? (0-10)'),
      MentorQuestionsContent(
          question: 'Rate your previous performance  (0-10)'),
      MentorQuestionsContent(
          question:
              'How confident are you that your performance will improve in the coming weeks? (0-10)'),
      MentorQuestionsContent(
          question: 'How helpful is your mentor overall for you? (0-10)'),
    ];
  }
}
