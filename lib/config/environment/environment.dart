class Environment {
  // api key
  static const apiKey = 'k4v9X8F1kqPz1LpYbG7aNzR6VnZ0TpQm';

  // api urls
  // static const baseUrl = 'http://api.weatherapi.com/v1';
  static const baseUrl = 'http://103.175.219.121:8001';
  static const apiUrl = '$baseUrl/api/v1';
  static const refreshUrl = '$apiUrl/auth/refresh';
  static const login = '$apiUrl/login';
  static const sentimentAnalysis = '$apiUrl/sentiment-analysis';
  static const scrapedData = '$apiUrl/scraped-data';
  static const sentimentStatistics = '$apiUrl/sentiment-statistics';

  // api fields
  static const key = 'key';
  static const q = 'q';
  static const days = 'days';
  static const lang = 'lang';

  // assets
  static const logo = 'assets/images/app_icon.png';
  static const welcome = 'assets/images/welcome.png';
  static const world = 'assets/images/world.png';
  static const world2 = 'assets/images/world2.png';
  static const noData = 'assets/images/no_data.png';
  static const search = 'assets/vectors/search.svg';
  static const language = 'assets/vectors/language.svg';
  static const category = 'assets/vectors/category.svg';
  static const downArrow = 'assets/vectors/down_arrow.svg';
  static const wind = 'assets/vectors/wind.svg';
  static const pressure = 'assets/vectors/pressure.svg';
  static const kemenhub = 'assets/images/logokemenhub.png';
  static const poltekpelBanten = 'assets/images/logo2.png';
  static const sentimen = 'assets/images/logo.png';

  static const weatherAnimation = 'assets/data/weather_animation.json';
}
