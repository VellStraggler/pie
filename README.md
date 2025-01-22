## Overview

**Project Title**:
Pie Chart Agenda

**Project Description**:
A mobile app, which will be compatible on IOS and Android, displays an agenda in a pie-chart format, following the 15-minute segments on a clock. It will allows you to write tasks and whole days that can auto-repeat, and it allows for easy task-editing and multiple views of the clock.

**Project Goals**:
To create a usable, professional, and easy-to-use application that helps keep a daily agenda.

## Instructions for Build and Use

Steps to build and/or run the software:

1. **Clone the repository:** 
    - Navigate to where you want to save the project in your terminal
    - Enter `git clone https://github.com/VellStraggler/pie`
2. **Install Dart/Flutter**
3. **Navigate to the Project:** In the terminal, enter `cd "address\to\saved\project\pie"`
    - Alternatively, open the project folder in an IDE.
4. **Run the Project:** Enter `flutter run` in the terminal.
    - Choose the device you wish to run the app on:
        * Web - Do not use this one except for testing. No saving.
        * Desktop - Saves your tasks and changes to a JSON file. 
        * Phone - Plug your phone in with USB debugging turned on. This will install the app to your phone and save automatically

## Instructions for using the software:

1. **Choose Time of Day:** Alternate between AM and PM by using the button in the bottom right corner.
2. **Add Tasks:** Press the + button and input the Start Time, Duration, and the Task Name.
3. **Adjust Tasks** Click on the task and dragging the white buttons on the edge of the slice to change the start and end times.
4. **Delete Tasks** Select a slice and select the delete button (trash can icon)
5. **View Tasks** Select the list view button to see what tasks you've made.

## Development Environment 
To recreate the development environment, you need the following software and/or libraries with the specified versions:

* [Visual Studio Code](https://code.visualstudio.com/Download)
    * Use your Windows10/11 IDE of choice (XCode, Visual Studio Code, Android Studio).
    * If using Visual Studio Code, also install Android Studio.
    * Set up a phone emulator if needed.
* [Install Flutter](https://docs.flutter.dev/get-started/install).
* [Install Git](https://git-scm.com/downloads)

## Software Features
* [x] Display a pie chart of the tasks for the day for 12 hours.
* [x] Ability to add tasks to pie chart
* [x] Hold and drag task edges to adjust times
* [x] Tap to edit a task
* [x] Delete Tasks
* [x] AM & PM Pie Charts
* [x] Date is shown in the corner
* [x] See a list of the tasks with their start and end time
* [X] Save and Load Tasks
* [ ] Edit Task Name

## Future Work
The following items we plan to fix, improve, and/or add to this project in the future:

* [X] Allow user to tap anywhere to deselect slices
* [ ] Stop tasks from overlapping
* [ ] Increase performance: [X]saving after tapping, not while holding
* [X] modify drawing to not overlap itself
* [ ] Limit to 2 drag buttons
* [ ] Add animations such as for loading / pie-switching
* [ ] Allow entire slice to be dragged
* [ ] widen click area for drag buttons
* [ ] allow double-tap editing
* [ ] allow military time task adding
* [ ] add time to markers 
* [ ] have time follow held dragbutton
* [ ] have a + and - button to change duration
* [ ] undo button
* [ ] future tasks brighter, old tasks duller/grayer, fading
* [ ] Allow transparency when editing tasks
* [ ] task buttons: start task, finish task
* [ ] lets you know how long it actually took
* [ ] improve base colors 
widget homescreen (what does this mean)
* [ ] fill space with details about current task
* [ ] import tasks from other calendar apps
* [ ] Swipe top bar to change day 
* [ ] Put AM/PM button in the center of the pie
* [X] Improve text sizing and centering
* [ ] Notifications
* [ ] Theme changing
* [ ] Allow it to run in the background when minimized

## Reflections
### What Went Well:
1.  Had very good attendance and we didn't lose any team members along the way
2.  Strong and constant communication over Discord and in class
3.  Worked hard to accomplish our specific tasks and were able to accomplish most of what we were hoping
### What can be improved upon:
1. Understanding GitHub and ensuring that we can work on the project together without overriding someone else work. We could do better at this by learning more about GitHub and ensuring tasks are separated so that we are not working on the same code at the same time.
2. Organization of code and modularization of classes. We hope to improve on this by creating a strong design layout before approaching the project
3. Ensuring that performance is optimized and that there are no unneeded functions running. We could improve on this by implementing peer code review to ensure that each function is optimal and necessary.

## Useful Websites to Learn More

We found these websites useful in developing this software:
* [Flutter Documentation](https://api.flutter.dev/index.html)
* [Codelabs Tutorial](https://codelabs.developers.google.com/codelabs/flutter-codelab-first#0)
* [Flutter Widgets You Should Learn](https://www.youtube.com/watch?v=YXvIxmmUoHU)
* [Flutter Design Layout](https://docs.flutter.dev/ui/layout/tutorial)