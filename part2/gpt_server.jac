import:py from transformers {pipeline}  # Import GPT-2 from Hugging Face

glob gpt_2_llm = pipeline("text-generation", model="gpt2");

import:jac from rag {RagEngine}
glob rag_engine:RagEngine = RagEngine();

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    # Ability to respond using GPT-2 instead of Ollama
    can llm_chat(
        message: str,
        chat_history: list[dict],
        agent_role: str,
        context: list
    ) -> str {
        # Generate response using GPT-2
        response = gpt_2_llm(message, max_length=100);
        return response[0]["generated_text"];
    }
}

walker interact {
    has message: str;
    has session_id: str;

    # Initialize the session
    can init_session with `root entry {
         visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");

            visit session_node;
        }
    }

    # Chat using GPT-2
    can chat with Session entry {
        # Add user message to chat history
        here.chat_history.append({"role": "user", "content": self.message});

        # Retrieve relevant documents from the RAG engine
        data = rag_engine.get_from_chroma(query=self.message);

        # Generate response using GPT-2
        response = here.llm_chat(
            message=self.message,
            chat_history=here.chat_history,
            agent_role="You are a conversation agent designed to help users with their queries based on the documents provided",
            context=data
        );

        # Add assistant response to chat history
        here.chat_history.append({"role": "assistant", "content": response});

        # Return the response to the frontend
        report {"response": response};
    }
}
