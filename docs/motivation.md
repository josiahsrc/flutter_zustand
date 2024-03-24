# Motivation

I have used other flutter state management libraries for many years. They are fantastic, well-built libraries. In general, however, I felt that state management in flutter was:

- Laborious
- Not productive
- Boilerplate heavy
- Sluggish to type
- Non-intuitive

I found myself saying things like this, over and over again:

- "Ok, now I have to place this in the build context somewhere"
- "Ah darn, I have to run the generator again"
- "How many times have I written this same thing?"

Recently, I had the pleasure to work with [zustand in react](https://github.com/pmndrs/zustand?tab=readme-ov-file). I was amazed at how quickly I was able to build new features, how little boiler plate I had to write, and how easy it was to maintain the code. I wanted to bring that same experience to Flutter.

The react zustand package leverages several javascript language features to make state management a breeze. Bearing in mind that this is dart, and some language features aren't 1:1 with javascript, this package aims to mirror the react zustand experience as closely as possible. Aiming to provide the following.

- Fast to type
- No boilerplate
- Less dependency on code generation
- Context-free usage
- Handle small and large scale apps gracefully
- Non-ceremonial

That said, this package is in its early stages. There may be some considerations that were overlooked. Please feel free to open an issue or PR if you have any suggestions.
