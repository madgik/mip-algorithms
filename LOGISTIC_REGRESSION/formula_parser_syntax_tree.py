import re
import ply.lex as lex
import ply.yacc as yacc


class Tree(object):
    "Generic tree node."

    def __init__(self, name='root', children=None):
        self.name = name
        self.children = []
        if children is not None:
            for child in children:
                self.add_child(child)

    def __repr__(self):
        if self.children != []:
            return self.name + repr(self.children)
        else:
            return self.name

    def add_child(self, node):
        assert isinstance(node, Tree)
        self.children.append(node)


# Input formula
# formula = input('Enter formula:\n')
formula = '(a*b):c'

# Format spaces
formula_fmt = formula.replace(' ', '') \
    .replace('+', ' + ') \
    .replace(':', ' : ') \
    .replace('*', ' * ')
print('Formula:')
print('  ' + formula)

# List of token names.
tokens = (
    'VAR',
    'NUMBER',
    'PLUS',
    'COLON',
    'STAR',
    'LPAREN',
    'RPAREN',
)

# Regular expression rules for simple tokens
t_VAR = r'(?!\*)[a-zA-Z][a-zA-Z_0-9]*(?!\*)'
t_NUMBER = r'(1|-1|0|-0)'
t_PLUS = r'\+'
t_COLON = r':'
t_STAR = r'\*'
t_LPAREN = r'\('
t_RPAREN = r'\)'

# A string containing ignored characters (spaces and tabs)
t_ignore = ' \t'


# Error handling rule
def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)


# Build the lexer
lexer = lex.lex()

# Give the lexer some input
lexer.input(formula_fmt)

# Tokenize
while True:
    tok = lexer.token()
    if not tok:
        break  # No more input
    # if tok.type == 'VAR' and tok.value not in VAR_NAMES:
    #     raise KeyError('No variable {}'.format(tok.value))
    print(tok)


# Yacc parser
def p_expression_plus(p):
    'expression : term PLUS expression'
    p[0] = Tree('+', [p[1], p[3]])


def p_expression_term(p):
    'expression : term'
    p[0] = p[1]


def p_term_colon(p):
    'term : factor COLON term'
    p[0] = Tree(':', [p[1], p[3]])


def p_term_star(p):
    'term : factor STAR term'
    p[0] = Tree('+', [Tree('+', [p[1], p[3]]),
                      Tree(':', [p[1], p[3]])])


def p_term_factor(p):
    'term : factor'
    p[0] = p[1]


def p_factor_expr(p):
    'factor : LPAREN expression RPAREN'
    p[0] = p[2]


def p_factor_var(p):
    'factor : VAR'
    p[0] = Tree(p[1], children=None)  # a VAR is a leaf


def p_factor_number(p):
    'factor : NUMBER'
    # if p[1] != '1':
    #     raise ValueError('NUMBER should only be 1 here')
    p[0] = Tree(p[1], children=None)  # a number is leaf


# Error rule for syntax errors
def p_error(p):
    print("Syntax error in input!")


# Build the parser
parser = yacc.yacc()

syntax_tree = parser.parse(formula_fmt)

print(syntax_tree)
