# intent_detector.py

import re
from chatbot.intents import INTENTS
from chatbot.data_extractors import (
    extract_height_weight,
    extract_activity_level
)
from chatbot.workout_handler import (
    extract_goal_from_text,
    extract_level_from_text
)


# =========================
# SAFE KEYWORD MATCHER
# =========================
def contains_phrase(message: str, phrases: list) -> bool:
    """
    Safely checks if a keyword or phrase exists in the message.

    - Single words must match as whole words only.
    - Multi-word phrases can match normally.

    This prevents false matches like:
    - 'fat' matching 'fatigued'
    - 'read' matching 'ready'
    - 'hi' matching 'this'
    """
    for phrase in phrases:
        phrase = phrase.lower().strip()

        if " " in phrase:
            if phrase in message:
                return True
        else:
            if re.search(rf"\b{re.escape(phrase)}\b", message):
                return True

    return False


def is_greeting_only(message: str, words: list) -> bool:
    """
    Detect greetings only if the message is short.
    This prevents 'hello I want workout' from becoming HELP.
    """
    greeting_words = [
        "hi", "hey", "hello", "yo", "sup", "hiya", "kamusta"
    ]

    if len(words) <= 3 and any(word in words for word in greeting_words):
        return True

    if message in [
        "good morning",
        "good afternoon",
        "good evening",
        "what's up",
        "whats up"
    ]:
        return True

    return False


def has_height_weight_context(message: str) -> bool:
    """
    Checks if the message really contains height or weight context.
    This prevents age-only messages from becoming BMI.
    """
    height_weight_keywords = [
        "cm", "centimeter", "centimeters",
        "kg", "kilogram", "kilograms",
        "lbs", "lb", "pounds", "pound",
        "height", "weight", "weigh",
        "feet", "foot", "ft", "inch", "inches",
        "tall"
    ]

    return contains_phrase(message, height_weight_keywords) or "'" in message


def is_age_only_message(message: str) -> bool:
    """
    Detects age-only inputs like:
    - 21 yrs old
    - 21 years old
    - age 21
    - I am 21
    - I'm 21

    These should NOT trigger BMI.
    """
    age_patterns = [
        r"\b\d+\s*(yrs?|years?)\s*old\b",
        r"\bage\s*[:\-]?\s*\d+\b",
        r"\bi am\s*\d+\b",
        r"\bim\s*\d+\b",
        r"\bi'm\s*\d+\b"
    ]

    return any(re.search(pattern, message) for pattern in age_patterns)


# =========================
# EMOTION SUPPORT KEYWORDS
# =========================
EMOTION_SUPPORT_KEYWORDS = [
    "i feel",
    "i am feeling",
    "frustrated",
    "overwhelmed",
    "tired",
    "sad",
    "burnt out",
    "burned out",
    "unmotivated",
    "giving up",
    "lazy",
    "hopeless",
    "stressed",
    "stress",
    "anxious",
    "worried",
    "i want to quit",
    "i can't do this",
    "i cant do this",
    "no progress",
    "i feel weak",
    "i feel down",
    "i am exhausted",
    "exhausted",
    "discouraged",
    "disappointed",
    "not improving",
    "i feel stuck",
    "stuck",
]


def detect_intent(message: str) -> str:
    message = message.lower().strip()

    # punctuation-safe word list
    words = re.findall(r"\b\w+\b", message)

    # =========================
    # CANCEL / RESET
    # =========================
    if message in [
        "cancel",
        "stop",
        "reset",
        "nevermind",
        "never mind",
        "forget it",
        "start over",
        "clear",
        "quit"
    ]:
        return "CANCEL"

    # =========================
    # READ FULL ARTICLE
    # =========================
    if contains_phrase(message, [
        "read more",
        "more details",
        "full article",
        "continue reading",
        "show full article",
        "show more",
        "continue article"
    ]):
        return "READ_MORE_ARTICLE"

    # =========================
    # EMOTION SUPPORT
    # Put this early to avoid emotional messages being detected as workout/calories.
    # =========================
    if contains_phrase(message, EMOTION_SUPPORT_KEYWORDS):
        return "EMOTION_SUPPORT"

    # =========================
    # ARTICLES / TIPS
    # =========================
    if contains_phrase(message, [
        "article",
        "articles",
        "tips",
        "guide",
        "advice",
        "information",
        "learn",
        "wellness",
        "health tips",
        "fitness tips",
        "weight loss tips",
        "nutrition tips",
        "healthy lifestyle",
        "recommend article",
        "read article",
        "give me tips",
        "give me advice",
        "health advice",
        "fitness advice"
    ]):
        return "ARTICLES"

    # =========================
    # MOTIVATION
    # =========================
    if contains_phrase(message, [
        "motivate",
        "motivation",
        "inspire",
        "inspiration",
        "motivated",
        "quote",
        "quotes",
        "encourage",
        "encouragement",
        "push me",
        "give me motivation",
        "i need motivation",
        "make me motivated",
        "inspire me",
        "encourage me"
    ]):
        return "MOTIVATION"

    # =========================
    # HELP / GREETINGS
    # =========================
    if is_greeting_only(message, words):
        return "HELP"

    if contains_phrase(message, [
        "help",
        "what can you do",
        "how to use",
        "commands",
        "features",
        "how does this work",
        "what do you do"
    ]):
        return "HELP"

    # =========================
    # BMI AUTO-DETECTION
    # =========================
    if contains_phrase(message, [
        "bmi",
        "body mass index",
        "calculate bmi",
        "check my bmi",
        "what is my bmi",
        "what's my bmi"
    ]):
        return "BMI"

    # Only detect BMI from height/weight if the message has height/weight context.
    # This prevents "21 yrs old" from becoming "weight: 21 kg".
    if not is_age_only_message(message) and has_height_weight_context(message):
        bmi_data = extract_height_weight(message)

        if bmi_data.get("height") or bmi_data.get("weight"):
            return "BMI"

    # =========================
    # CALORIES / FOOD / DIET
    # =========================
    if extract_activity_level(message):
        return "CALORIES"

    if contains_phrase(message, [
        "calorie",
        "calories",
        "kcal",
        "eat",
        "food",
        "meal",
        "meals",
        "diet",
        "nutrition",
        "protein",
        "carbs",
        "carbohydrates",
        "breakfast",
        "lunch",
        "dinner",
        "snack",
        "snacks",
        "what should i eat",
        "meal plan",
        "diet plan",
        "healthy food",
        "filipino food",
        "how many calories",
        "daily calories",
        "calorie goal",
        "daily calorie goal",
        "what food",
        "what meal",
        "food suggestion",
        "meal suggestion"
    ]):
        return "CALORIES"

    # =========================
    # WORKOUT AUTO-DETECTION
    # =========================
    workout_keywords = [
        "workout",
        "workouts",
        "exercise",
        "exercises",
        "training",
        "train",
        "fitness plan",
        "exercise plan",
        "routine",
        "workout plan",
        "program",

        "build muscle",
        "gain muscle",
        "gain muscles",
        "build muscles",
        "muscle gain",
        "strength",
        "strength training",
        "get stronger",
        "get toned",

        "lose weight",
        "weight loss",
        "fat loss",
        "burn fat",
        "belly fat",
        "slim down",
        "get fit",
        "keep fit",
        "stay fit",

        "beginner workout",
        "intermediate workout",
        "advanced workout",
        "home workout",
        "bodyweight workout",
        "cardio",
        "abs",
        "legs",
        "arms",
        "chest",
        "back workout",
        "leg workout",
        "arm workout",
        "chest workout",
        "abs workout"
    ]

    if contains_phrase(message, workout_keywords):
        return "WORKOUT"

    if extract_goal_from_text(message) or extract_level_from_text(message):
        return "WORKOUT"

    # =========================
    # FALLBACK
    # =========================
    return "UNKNOWN"