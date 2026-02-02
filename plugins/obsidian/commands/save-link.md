---
description: Save external link to Obsidian note's external links table
argument-hint: [url] [optional:note-path]
allowed-tools: mcp__obsidian-zettelkasten__save_external_link,AskUserQuestion
---

# Save External Link

This command saves an external link to an Obsidian note's external links table. If the note doesn't exist, it will be created automatically.

## Usage

The command accepts a URL and optionally a note path:
- URL (required): The external link to save
- Note path (optional): Path to the note where the link should be saved (e.g., "ai/outlinks")

## Process

1. Extract URL from arguments (or prompt if not provided)
2. Prompt for link title/description
3. Prompt for note path (if not provided as argument)
4. Optionally ask for tags to add
5. Optionally ask for notes/context
6. Save the link using the MCP tool
7. Report success

## Implementation

Extract the URL and optional note path from the arguments. If URL is missing, ask the user for it.

Ask the user for a title/description for the link:
- Use AskUserQuestion to get a descriptive title
- This will be the display text for the link

If note path wasn't provided as an argument, ask the user where to save the link:
- Suggest common locations like "ai/outlinks", "resources", "references"
- Allow the user to specify any path

Ask if the user wants to add any tags (optional):
- These are in addition to the auto-generated source tag
- Present as optional multi-line input

Ask if the user wants to add notes or context about the link (optional):
- This helps remember why the link was saved
- Present as optional text input

Call the save_external_link MCP tool with:
- url: the URL from arguments or user
- title: the description from user
- notePath: from arguments or user prompt
- tags: array of tags if provided, otherwise empty array
- notes: the notes text if provided, otherwise empty string
- createIfMissing: true (to create the note if it doesn't exist)

Report success by showing:
- The note path where the link was saved
- Confirmation that the link was added to the external links table
- Note if the note was newly created

If there's an error, explain what went wrong and suggest how to fix it.
