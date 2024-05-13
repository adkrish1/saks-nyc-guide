from flask import Flask, request, jsonify
from langchain_community.utilities import SQLDatabase
from langchain_community.chat_models.ollama import ChatOllama
from langchain_community.tools.sql_database.tool import QuerySQLDataBaseTool
from langchain.chains import create_sql_query_chain

from operator import itemgetter
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnablePassthrough

from langchain_openai import ChatOpenAI
import os
import json

app = Flask(__name__)

endpoint = 'llmdata.cxouquo4mbsy.us-east-1.rds.amazonaws.com'
port = '3306'
db_name = 'sampledb'
username = 'admin'
password = 'saksnyc123'

uri = f'mysql+pymysql://{username}:{password}@{endpoint}:{port}/{db_name}'

db = SQLDatabase.from_uri(uri)
print(db.dialect)
print(db.get_usable_table_names())


#llm = ChatOllama(model="codellama")
os.environ["OPENAI_API_KEY"] = "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"
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)

execute_query = QuerySQLDataBaseTool(db=db)
write_query = create_sql_query_chain(llm, db)

answer_prompt = PromptTemplate.from_template(
    """Given the following user question, corresponding SQL query, and SQL result, answer the user questi>

Question: {question}
SQL Query: {query}
SQL Result: {result}
Answer: """
)

answer = answer_prompt | llm | StrOutputParser()
chain = (
    RunnablePassthrough.assign(query=write_query).assign(
        result=itemgetter("query") | execute_query
    )
    | answer
)

#response = chain.invoke({"question": "Give me 7 restaurant with rating more than 3"})
#print(response)



#def process_question(question):
#    return question

def process_question(question):

    response = chain.invoke({"question": question})
    print(response)
    json_response = json.loads(response)

    return json_response

@app.route('/llm', methods=['GET'])
def ask_question():
    # Check if 'question' parameter is present in the request query string
    if 'question' in request.args:
        question = request.args['question']

        response = process_question(question)
        return jsonify({'response': response})
    else:
        return jsonify({'error': 'No question provided'})

@app.route('/')
def hello_world():
        return 'Hello World!'

if __name__ == "__main__":
        app.run(host='0.0.0.0',debug=True,port=6969)
