#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, redirect, url_for, request

## PostgreSQL database adapter
import psycopg2
import psycopg2.extras

app = Flask(__name__)

## SGBD configs
DB_HOST="db.tecnico.ulisboa.pt"
DB_USER="ist198938" 
DB_DATABASE=DB_USER
DB_PASSWORD="ostx1739"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

@app.route('/')
def home():
  return render_template("index.html")

@app.route('/form_supercategory', methods=["POST", "GET"])
def form_supercategory():
  if request.method == "POST":
    supercategory = request.form["name"]
    return redirect(url_for("list_subcategories", name=supercategory))
  else:
    return render_template("form_supercategory.html")

@app.route('/list_subcategories/<name>')
def list_subcategories(name):
  connection=None
  cursor=None
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    query = '''WITH RECURSIVE supercat AS(SELECT categoria FROM tem_outra WHERE super_categoria = %s UNION SELECT cat.categoria FROM tem_outra cat, supercat WHERE cat.super_categoria = supercat.categoria)SELECT * FROM supercat;'''
    cursor.execute(query, (name,))

    rowcount=cursor.rowcount
    
    html='''      
    <!DOCTYPE html>
      <html>
        <head>
        <style>
          h1 {font-family:'Lato', sans-serif; font-weight: 700;}
          h3 {font-family:'Lato', sans-serif; font-weight: 500;}
          body {background-image: url(../../img.jpg);}
          hr {border: none; height: 3px; background: black;}
          table {background-color: white;}
        </style>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>List Sub-categories</title>
        </head>
        <body style="padding:20px;">
          <h1>Projeto de Base de Dados - Entrega 3</h1>
          <h3>Listar todas as subcategorias de uma supercategoria</h3>
          <hr><br>
    
        <table border="4" cellpadding="10">
          <tr>
            <th>Subcategorias</th>
          </tr>

    '''
    for record in cursor:
      html+=f'''
                <tr>
                  <td>{record[0]}</td>
              </tr>
      ''' 
    html+='''
            </table>
      </body>
    </doctype>
    '''
    return html 
  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

@app.route('/form_ivm', methods=["POST", "GET"])
def form_ivm():
  if request.method == "POST":
    num_serie = request.form["num"]
    fabr = request.form["fabr"]
    return redirect(url_for("list_events", num=num_serie, fabricante=fabr))
  else:
    return render_template("form_ivm.html")

@app.route('/list_events/<num>&<fabricante>')
def list_events(num, fabricante):
  connection=None
  cursor=None
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    query = '''SELECT nome, SUM(unidades) FROM evento_reposicao JOIN tem_categoria ON evento_reposicao.ean = tem_categoria.ean WHERE num_serie = %s AND fabricante = %s GROUP BY nome;'''
    cursor.execute(query, (num, fabricante))

    rowcount=cursor.rowcount
    
    html='''      
    <!DOCTYPE html>
      <html>
        <head>
        <style>
          h1 {font-family:'Lato', sans-serif; font-weight: 700;}
          h3 {font-family:'Lato', sans-serif; font-weight: 500;}
          body {background-image: url(../../img.jpg);}
          hr {border: none; height: 3px; background: black;}
          table {background-color: white;}
        </style>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>List Replenishment Events</title>
        </head>
        <body style="padding:20px;">
          <h1>Projeto de Base de Dados - Entrega 3</h1>
          <h3>Listar todos os eventos de reposição de uma IVM</h3>
          <hr><br>
    
        <table border="4" cellpadding="10">
          <tr>
            <th>Categoria</th>
            <th>Unidades</th>
          </tr>

    '''
    for record in cursor:
      html+=f'''
                <tr>
                  <td>{record[0]}</td>
                  <td>{record[1]}</td>
              </tr>
      ''' 
    html+='''
            </table>
      </body>
    </doctype>
    '''
    return html 
  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

@app.route('/insert_remove_retailers')
def insert_remove_retailers():
  return render_template("insert_remove_retailer.html")

@app.route('/form_insert_retailer', methods=["POST", "GET"])
def form_insert_retailer():
  if request.method == "POST":
    retailer = request.form["retailer"]
    t = request.form["tin"]
    return redirect(url_for("insert_retailer", ret=retailer, tin=t))
  else:
    return render_template("insert_retailer.html")

@app.route('/insert_retailer/<ret>/<tin>')
def insert_retailer(ret,tin):
  connection=None
  cursor=None
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    query1 = '''INSERT INTO retalhista VALUES (%s, %s);'''
    cursor.execute(query1, (tin, ret))
    connection.commit()

    rowcount=cursor.rowcount

    return render_template("success.html")

  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

@app.route('/form_remove_retailer', methods=["POST", "GET"])
def form_remove_retailer():
  if request.method == "POST":
    t = request.form["tin"]
    return redirect(url_for("remove_retailer", tin=t))
  else:
    return render_template("remove_retailer.html")

@app.route('/remove_retailer/<tin>')
def remove_retailer(tin):
  connection=None
  cursor=None
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)

    produto = '''SELECT ean FROM produto WHERE cat IN (SELECT nome_cat FROM responsavel_por WHERE tin = %s);'''
    cursor.execute(produto, (tin,))
    result = cursor.fetchall()

    for row in result:
      for value in row:
        query1 = '''DELETE FROM tem_categoria WHERE ean = %s;'''
        query2 = '''DELETE FROM evento_reposicao WHERE ean = %s;'''
        query3 = '''DELETE FROM evento_reposicao WHERE tin = %s;'''
        query4 = '''DELETE FROM planograma WHERE ean = %s;'''
        query5 = '''DELETE FROM produto WHERE ean = %s;'''
        query6 = '''DELETE FROM responsavel_por WHERE tin = %s;'''
        query7 = '''DELETE FROM retalhista WHERE tin = %s;'''
        cursor.execute(query1, (value,))
        cursor.execute(query2, (value,))
        cursor.execute(query3, (tin,))
        cursor.execute(query4, (value,))
        cursor.execute(query5, (value,))
        cursor.execute(query6, (tin,))
        cursor.execute(query7, (tin,))
        connection.commit()

    rowcount=cursor.rowcount

    return render_template("success.html")

  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

@app.route('/insert_remove_categories')
def insert_remove_categories():
  return render_template("insert_remove_category.html")

@app.route('/insert_category_subcategory')
def insert_category_subcategory():
  return render_template("category_subcategory_insert.html")

@app.route('/form_insert_category', methods=["POST", "GET"])
def form_insert_category():
  if request.method == "POST":
    nome = request.form["nome"]
    return redirect(url_for("insert_category", cat_name=nome))
  else:
    return render_template("insert_category.html")

@app.route('/insert_category/<cat_name>')
def insert_category(cat_name):
  connection=None
  cursor=None
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    query1 = '''INSERT INTO categoria VALUES (%s);'''
    query2 = '''INSERT INTO categoria_simples VALUES (%s);'''
    cursor.execute(query1, (cat_name,))
    cursor.execute(query2, (cat_name,))
    connection.commit()

    rowcount=cursor.rowcount

    return render_template("success.html")

  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

@app.route('/form_insert_subcategory', methods=["POST", "GET"])
def form_insert_subcategory():
  if request.method == "POST":
    nome = request.form["nome"]
    supercat = request.form["supercat"]
    return redirect(url_for("insert_subcategory", cat_name=nome, supercategory=supercat))
  else:
    return render_template("insert_subcategory.html")

@app.route('/insert_subcategory/<cat_name>/<supercategory>')
def insert_subcategory(cat_name, supercategory):
  connection=None
  cursor=None
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    supercat_exists = 0
    cat_exists = 0

    test = '''SELECT nome FROM super_categoria WHERE nome = %s;'''
    cursor.execute(test, (supercategory,))
    result = cursor.fetchall()

    for row in result:
      for value in row:
        if value == supercategory:
          supercat_exists = 1

    test = '''SELECT nome FROM categoria WHERE nome = %s;'''
    cursor.execute(test, (supercategory,))
    result = cursor.fetchall()

    for row in result:
      for value in row:
        if value == supercategory:
          cat_exists = 1

    if supercat_exists == 0 and cat_exists == 0:
      query1 = '''DELETE FROM categoria_simples WHERE nome = %s;'''
      query2 = '''INSERT INTO categoria VALUES (%s);'''
      query3 = '''INSERT INTO categoria VALUES (%s);'''
      query4 = '''INSERT INTO categoria_simples VALUES (%s);'''
      query5 = '''INSERT INTO super_categoria VALUES (%s);'''
      query6 = '''INSERT INTO tem_outra VALUES (%s, %s);'''
      cursor.execute(query1, (supercategory,))
      cursor.execute(query2, (cat_name,))
      cursor.execute(query3, (supercategory,))
      cursor.execute(query4, (cat_name,))
      cursor.execute(query5, (supercategory,))
      cursor.execute(query6, (supercategory, cat_name))
      connection.commit

    if supercat_exists == 0 and cat_exists == 1:
      query1 = '''DELETE FROM categoria_simples WHERE nome = %s;'''
      query2 = '''INSERT INTO categoria VALUES (%s);'''
      query3 = '''INSERT INTO categoria_simples VALUES (%s);'''
      query4 = '''INSERT INTO super_categoria VALUES (%s);'''
      query5 = '''INSERT INTO tem_outra VALUES (%s, %s);'''
      cursor.execute(query1, (supercategory,))
      cursor.execute(query2, (cat_name,))
      cursor.execute(query3, (cat_name,))
      cursor.execute(query4, (supercategory,))
      cursor.execute(query5, (supercategory, cat_name))
      connection.commit()

    if supercat_exists == 1:
      query1 = '''INSERT INTO categoria VALUES (%s);'''
      query2 = '''INSERT INTO categoria_simples VALUES (%s);'''
      query3 = '''INSERT INTO tem_outra VALUES (%s, %s);'''
      cursor.execute(query1, (cat_name,))
      cursor.execute(query2, (cat_name,))
      cursor.execute(query3, (supercategory, cat_name))
      connection.commit()

    rowcount=cursor.rowcount

    return render_template("success.html")

  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

@app.route('/form_remove_category', methods=["POST", "GET"])
def form_remove_category():
  if request.method == "POST":
    cat = request.form["category"]
    return redirect(url_for("remove_category", category=cat))
  else:
    return render_template("remove_category.html")

@app.route('/remove_category/<category>')
def remove_category(category):
  connection=None
  cursor=None
  
  try:
    connection = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    is_supercat = 0

    test = '''SELECT nome FROM super_categoria WHERE nome = %s'''
    cursor.execute(test, (category,))
    result = cursor.fetchall()

    for row in result:
      for value in row:
        if value == category:
          is_supercat = 1

    if is_supercat == 0:
      query1 = '''DELETE FROM evento_reposicao WHERE ean IN (SELECT ean FROM produto WHERE cat = %s);'''
      query2 = '''DELETE FROM planograma WHERE ean IN (SELECT ean FROM produto WHERE cat = %s);'''
      query3 = '''DELETE FROM prateleira WHERE nome = %s;'''
      query4 = '''DELETE FROM tem_categoria WHERE nome = %s;'''
      query5 = '''DELETE FROM produto WHERE cat = %s;'''
      query6 = '''DELETE FROM tem_outra WHERE categoria = %s;'''
      query7 = '''DELETE FROM tem_outra WHERE super_categoria = %s;'''
      query8 = '''DELETE FROM categoria_simples WHERE nome = %s;'''
      query9 = '''DELETE FROM super_categoria WHERE nome = %s;'''
      query10 = '''DELETE FROM responsavel_por WHERE nome_cat = %s;'''
      query11 = '''DELETE FROM categoria WHERE nome = %s;'''
      cursor.execute(query1, (category,))
      cursor.execute(query2, (category,))
      cursor.execute(query3, (category,)) 
      cursor.execute(query4, (category,)) 
      cursor.execute(query5, (category,)) 
      cursor.execute(query6, (category,))
      cursor.execute(query7, (category,)) 
      cursor.execute(query8, (category,))
      cursor.execute(query9, (category,))
      cursor.execute(query10, (category,))
      cursor.execute(query11, (category,))         
      connection.commit()

    if is_supercat == 1:
      test = '''SELECT categoria FROM tem_outra WHERE super_categoria = %s;'''
      cursor.execute(test, (category,))
      result = cursor.fetchall()
      aux = result
     
      i = 0

      while aux:
        for row in aux:
          for value in row:
            test = '''SELECT categoria FROM tem_outra WHERE super_categoria = %s;'''
            cursor.execute(test, (value,))
            aux = cursor.fetchall()
            result += aux
            i += 1
      query1 = '''DELETE FROM evento_reposicao WHERE ean IN (SELECT ean FROM produto WHERE cat = %s);'''
      query2 = '''DELETE FROM planograma WHERE ean IN (SELECT ean FROM produto WHERE cat = %s);'''
      query3 = '''DELETE FROM prateleira WHERE nome = %s;'''
      query4 = '''DELETE FROM tem_categoria WHERE nome = %s;'''
      query5 = '''DELETE FROM produto WHERE cat = %s;'''
      query6 = '''DELETE FROM tem_outra WHERE categoria = %s;'''
      query7 = '''DELETE FROM tem_outra WHERE super_categoria = %s;'''
      query8 = '''DELETE FROM categoria_simples WHERE nome = %s;'''
      query9 = '''DELETE FROM super_categoria WHERE nome = %s;'''
      query10 = '''DELETE FROM responsavel_por WHERE nome_cat = %s;'''
      query11 = '''DELETE FROM categoria WHERE nome = %s;'''
      cursor.execute(query1, (category,))
      cursor.execute(query2, (category,))
      cursor.execute(query3, (category,)) 
      cursor.execute(query4, (category,)) 
      cursor.execute(query5, (category,)) 
      cursor.execute(query6, (category,))
      cursor.execute(query7, (category,)) 
      cursor.execute(query8, (category,))
      cursor.execute(query9, (category,))
      cursor.execute(query10, (category,))
      cursor.execute(query11, (category,))

      for row in result:
        for value in row:
          query1 = '''DELETE FROM evento_reposicao WHERE ean IN (SELECT ean FROM produto WHERE cat = %s);'''
          query2 = '''DELETE FROM planograma WHERE ean IN (SELECT ean FROM produto WHERE cat = %s);'''
          query3 = '''DELETE FROM prateleira WHERE nome = %s;'''
          query4 = '''DELETE FROM tem_categoria WHERE nome = %s;'''
          query5 = '''DELETE FROM produto WHERE cat = %s;'''
          query6 = '''DELETE FROM tem_outra WHERE categoria = %s;'''
          query7 = '''DELETE FROM tem_outra WHERE super_categoria = %s;'''
          query8 = '''DELETE FROM categoria_simples WHERE nome = %s;'''
          query9 = '''DELETE FROM super_categoria WHERE nome = %s;'''
          query10 = '''DELETE FROM responsavel_por WHERE nome_cat = %s;'''
          query11 = '''DELETE FROM categoria WHERE nome = %s;'''
          cursor.execute(query1, (value,))
          cursor.execute(query2, (value,))
          cursor.execute(query3, (value,)) 
          cursor.execute(query4, (value,)) 
          cursor.execute(query5, (value,)) 
          cursor.execute(query6, (value,))
          cursor.execute(query7, (value,)) 
          cursor.execute(query8, (value,))
          cursor.execute(query9, (value,))
          cursor.execute(query10, (value,))
          cursor.execute(query11, (value,))
        connection.commit()

    return render_template("success.html")

  except Exception as e:
    return str(e)
  finally:
    cursor.close()
    connection.close()

CGIHandler().run(app)
