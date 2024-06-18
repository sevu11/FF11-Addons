import discord
import asyncio
import sys

Token = 'Token Goes Here'


def clear_file(file_path):
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write('')

def read_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

async def monitor_file_changes(channel, file_path, user_id):
    while True:
        file_content = read_file(file_path)
        if file_content:
            message_lines = file_content.splitlines()
            if message_lines:
                message_content = f'{message_lines[0]}' 
                await channel.send(message_content)  
                clear_file(file_path)  
        await asyncio.sleep(2)  

intents = discord.Intents.default()
client = discord.Client(intents=intents)
channel_id = Channel ID Here
user_id = 0
message_file = sys.argv[1]

@client.event
async def on_ready():
    print('Bot is online.')
    channel = client.get_channel(channel_id)
    if channel:
        asyncio.create_task(monitor_file_changes(channel, message_file, user_id))

client.run(Token)