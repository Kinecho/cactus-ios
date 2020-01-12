# Cactus iOS App

# Abouot the Journal Feed Data Source
There are several steps to initialize a new JournaFeedData Source. Each will be described in detail in the coming sections.

1) Set Up SentPrompts for pagination
2) Set Up Today's Prompt
3) Handle Data Changes 
4) Rendering Data

## Set Up SentPrompts for pagination
Sets up PageLoaders for the user's sent prompts. A PageLoader is a class that knows how to set up and query for, and notify an delegate on changes for a specific page of data. Two page loaders are created when the DataSource is initialized: 

1) Listen for the first page of prompts, starting at the current date and looking backwards in time. This is a classic page loader with a a page size limit of something like 10 (or within that magnitude). 

2) Listen for all future SentPrompts using a PageLoader with _no limit_ looking at data that has a sentAt _after_ the current date. 

## Setup Today's Prompt 
In addition to the page loaders, a separate process is initialize to manage Today's Prompt. A query is run to fetch the current day's PromptContent - using the local device's day of the month - from Flamelink (via firestore). 

When/if the current PromptContent is fetched, set up a JournalEntryData instance for the promptId. Set `isTodaysPrompt=true` on the JournalEntryData, which will be leveraged in the view code to display the correct date label. Store this as `todayData` on the JournalFeedDataSource, along with the local date string that was used to fetch the prompt. Using a string is important to detect future calendar date changes. 


### Listen for calendar date changes
A NotificationCenter observer is added to listen for calendar date changes using the notification `NSCalendarDayChanged`. Whe this nofification is fired, the same code to set up today's prompt is re-run, which checks to see if the last fetched dateString has changed. If no date change has occurred, no action is taken. If the date has changed, fresh data is fetched. 

## Handle Data Changes
### Added/Removed Entries to DataFeed
When new entrie are loaded we need to tell the view to add new CollectionViewCells. If the entry isn't fully loaded (controlled by JournalEntryData), it will render as a skeleton state. 

This method only cares about additions and subtractions to the set of prompts that should be displayed in the feed. 

After a page of data is fetched or the today's content has changed, the method `configureDataFeed` is called. This method takes all the various bits of data - the pages, the sent prompts, the today's prompt, and puts it into order. It will also create new JournalEntryData objects as needed. 

The primary output of this function is to produce the `orderedPromptIds` array, which is a sorted list of promptIds to display on the journal feed. This array drives all attributes of thte JournalFeedCollection view. 

Once this method finishes, the DataSource will notify the delegate of any additions or deletions, using the batch operation where applicable. 

### Updates to a single JournalEntry
When a single entry is updated, the journal feed collection view needs to update the corresponding cell. To do this, each JournalEntryData object will notify its delegate when a change has occurred. This delegate is set to be the JournalFeedDataSource itself, which in turn calls its own delegate to notify that a specific index of the journal feed has been updated, allowing the View to re-render its contents. 

