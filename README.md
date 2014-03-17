# MiniZork
## About
This is a basic quest game written in Ruby with Sinatra, and given a deliberately retro look. The object is to collect gems, avoid the grue, and reach the goal alive once you collect five gems (six, if you include the freebie). Entering the grue's room causes it to flee one room away--selected at random--and drop a gem, which you automatically pick up. 

Since this is basically a demo, locations for the grue and gems are given on each turn, so you may actively try to avoid or intercept it, instead of running around blind. These settings can be changed using the form on the left. You can also switch between template systems, though there's not much of a visual difference, there (the ERB templates use the original stylesheet, while the others use the Sass-ified one).

#### On Heroku: 
http://safe-sands-4182.herokuapp.com/

## To Do 
Finish writing specs, refactor, and stop doing TDD backwards (more of a long-term goal, there). Make the layout fluid (maybe find a more eye-cancerous shade of chartreuse), and maybe set up a form to allow users to upload map files, or something. If I'm feeling really ambitious, I'll read up on actual pathing algorithms and try to use one, especially since the recent versions of the RubyTree gem break the app.

## License
Apparently, someone stumbled across this and forked it--wasn't really expecting that :-p. So, I'm throwing the MIT license on the code, for anyone else who happens to stumble upon it.

## Credits
"Green Screen" font designed by James Shields, available at http://www.lostcarpark.com/fonts/