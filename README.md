# WiktiScraperV2

Webscraping system designed to create APIs for languages from wiktionary.

Workflow:

Choose a language:

![image](https://user-images.githubusercontent.com/8331627/123488969-0730e400-d5df-11eb-9544-e6a1b4c2113e.png)

Languages are automatically generated by reading the HTML of Wiktionary.

Choose a lemma:

![image](https://user-images.githubusercontent.com/8331627/123489085-3e06fa00-d5df-11eb-84c3-8e48fa2811a9.png)

Generate unmatched words - scrapes each word in the lemma into an unitialized form, later to be defined into your prefered structure:

![image](https://user-images.githubusercontent.com/8331627/123489370-d0a79900-d5df-11eb-96ff-79d98e830589.png)

Choose a word - words in this lemma with like-HTML structures are hidden and will have your changes applied to them as well:

![image](https://user-images.githubusercontent.com/8331627/123489671-78bd6200-d5e0-11eb-86ec-b62b5fbfbf8e.png)

Define structure - choose which elements from the page to store in the database, giving them your desired name:

![image](https://user-images.githubusercontent.com/8331627/123489532-3136d600-d5e0-11eb-8bd6-f1ce36f7ed57.png)

Generate definitions - Any pages with structures the same as you have defined will be saved in the database as queryable objects according to your input:

![image](https://user-images.githubusercontent.com/8331627/123489536-3431c680-d5e0-11eb-93e3-4ff788c15b4e.png)
