conversation_memory = []

MAX_HISTORY = 10

def add_message(role: str, content: str):
    conversation_memory.append({
        "role": role,
        "content": content
    })

    if len(conversation_memory) > MAX_HISTORY:
        conversation_memory.pop(0)

def get_memory():
    system_prompt = {
        "role": "system",
        "content": (
            "Ti si Brko, prijateljski glasovni asistent. "
            "Pričaš bosanski/hrvatski jezik, jednostavno, jasno i prirodno. "
            "Odgovaraš konkretno i kratko."
        )
    }

    return [system_prompt] + conversation_memory
