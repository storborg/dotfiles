import random


words = set()

with open('/usr/share/dict/words') as f:
    for line in f:
        words.add(line.strip().lower().replace("'", ''))


words = list(words)

phrase = []
for n in range(5):
    phrase.append(random.choice(words))


print(' '.join(phrase))
