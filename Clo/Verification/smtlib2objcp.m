/* -*- C -*-
 *
 * SMT-LIB v2 interface to objcp 1
 *
 * Author: Alberto Griggio <griggio@fbk.eu>
 *
 * Copyright (C) 2010 Alberto Griggio
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <stdlib.h>
#include <string.h>
#include "smtlib2objcp.h"
#include "/usr/local/include/gmp.h"

OBJCPGateway* objcpgw;

static void smtlib2_objcp_parser_set_logic(smtlib2_parser_interface *p,
                                           const char *logic);
static void smtlib2_objcp_parser_declare_sort(smtlib2_parser_interface *p,
                                              const char *sortname,
                                              int arity);
static void smtlib2_objcp_parser_define_sort(smtlib2_parser_interface *p,
                                             const char *sortname,
                                             smtlib2_vector *params,
                                             smtlib2_sort sort);
static void smtlib2_objcp_parser_declare_function(smtlib2_parser_interface *p,
                                                  const char *name,
                                                  smtlib2_sort sort);
static void smtlib2_objcp_parser_define_function(smtlib2_parser_interface *p,
                                                 const char *name,
                                                 smtlib2_vector *params,
                                                 smtlib2_sort sort,
                                                 smtlib2_term term);
static smtlib2_sort smtlib2_objcp_parser_make_sort(smtlib2_parser_interface *p,
                                                   const char *sortname,
                                                   smtlib2_vector *index);
static smtlib2_sort smtlib2_objcp_parser_make_function_sort(
                                                    smtlib2_parser_interface *p,
                                                    smtlib2_vector *tps);
static smtlib2_sort smtlib2_objcp_parser_make_parametric_sort(
                                                    smtlib2_parser_interface *p,
                                                    const char *name,
                                                    smtlib2_vector *tps);

static void smtlib2_objcp_parser_push(smtlib2_parser_interface *p, int n);
static void smtlib2_objcp_parser_pop(smtlib2_parser_interface *p, int n);
static void smtlib2_objcp_parser_assert_formula(smtlib2_parser_interface *p,
                                                smtlib2_term term);
static void smtlib2_objcp_parser_check_sat(smtlib2_parser_interface *p);

static void smtlib2_objcp_parser_annotate_term(smtlib2_parser_interface *p,
                                               smtlib2_term term,
                                               smtlib2_vector *annotations);
static void smtlib2_objcp_parser_set_int_option(smtlib2_parser_interface *p,
                                                const char *keyword,
                                                int value);
static void smtlib2_objcp_parser_get_assignment(smtlib2_parser_interface *p);
static void smtlib2_objcp_parser_get_value(smtlib2_parser_interface *p,
                                           smtlib2_vector *terms);
static void smtlib2_objcp_parser_get_unsat_core(smtlib2_parser_interface *p);

static smtlib2_term smtlib2_objcp_parser_mk_function(smtlib2_context ctx,
                                                     const char *symbol,
                                                     smtlib2_sort sort,
                                                     smtlib2_vector *index,
                                                     smtlib2_vector *args);
static smtlib2_term smtlib2_objcp_parser_mk_number(smtlib2_context ctx,
                                                   const char *rep,
                                                   unsigned int width,
                                                   unsigned int base);
#define SMTLIB2_OBJCP_DECLHANDLER(name) \
    static smtlib2_term smtlib2_objcp_parser_mk_ ## name (              \
        smtlib2_context ctx,                                            \
        const char *symbol,                                             \
        smtlib2_sort sort,                                              \
        smtlib2_vector *idx,                                            \
        smtlib2_vector *args)

SMTLIB2_OBJCP_DECLHANDLER(and);
SMTLIB2_OBJCP_DECLHANDLER(or);
SMTLIB2_OBJCP_DECLHANDLER(not);
SMTLIB2_OBJCP_DECLHANDLER(implies);
SMTLIB2_OBJCP_DECLHANDLER(eq);
SMTLIB2_OBJCP_DECLHANDLER(plus);
SMTLIB2_OBJCP_DECLHANDLER(times);
SMTLIB2_OBJCP_DECLHANDLER(minus);
SMTLIB2_OBJCP_DECLHANDLER(leq);
SMTLIB2_OBJCP_DECLHANDLER(lt);
SMTLIB2_OBJCP_DECLHANDLER(geq);
SMTLIB2_OBJCP_DECLHANDLER(gt);
SMTLIB2_OBJCP_DECLHANDLER(ite);
SMTLIB2_OBJCP_DECLHANDLER(divide);
SMTLIB2_OBJCP_DECLHANDLER(distinct);
SMTLIB2_OBJCP_DECLHANDLER(xor);
SMTLIB2_OBJCP_DECLHANDLER(nand);
SMTLIB2_OBJCP_DECLHANDLER(to_real);

SMTLIB2_OBJCP_DECLHANDLER(concat);
SMTLIB2_OBJCP_DECLHANDLER(bvnot);
SMTLIB2_OBJCP_DECLHANDLER(bvand);
SMTLIB2_OBJCP_DECLHANDLER(bvnand);
SMTLIB2_OBJCP_DECLHANDLER(bvor);
SMTLIB2_OBJCP_DECLHANDLER(bvnor);
SMTLIB2_OBJCP_DECLHANDLER(bvxor);
SMTLIB2_OBJCP_DECLHANDLER(bvxnor);
SMTLIB2_OBJCP_DECLHANDLER(bvult);
SMTLIB2_OBJCP_DECLHANDLER(bvslt);
SMTLIB2_OBJCP_DECLHANDLER(bvule);
SMTLIB2_OBJCP_DECLHANDLER(bvsle);
SMTLIB2_OBJCP_DECLHANDLER(bvugt);
SMTLIB2_OBJCP_DECLHANDLER(bvsgt);
SMTLIB2_OBJCP_DECLHANDLER(bvuge);
SMTLIB2_OBJCP_DECLHANDLER(bvsge);
SMTLIB2_OBJCP_DECLHANDLER(bvcomp);
SMTLIB2_OBJCP_DECLHANDLER(bvneg);
SMTLIB2_OBJCP_DECLHANDLER(bvadd);
SMTLIB2_OBJCP_DECLHANDLER(bvsub);
SMTLIB2_OBJCP_DECLHANDLER(bvmul);
SMTLIB2_OBJCP_DECLHANDLER(bvudiv);
SMTLIB2_OBJCP_DECLHANDLER(bvsdiv);
SMTLIB2_OBJCP_DECLHANDLER(bvsmod);
SMTLIB2_OBJCP_DECLHANDLER(bvurem);
SMTLIB2_OBJCP_DECLHANDLER(bvsrem);
SMTLIB2_OBJCP_DECLHANDLER(bvshl);
SMTLIB2_OBJCP_DECLHANDLER(bvlshr);
SMTLIB2_OBJCP_DECLHANDLER(bvashr);
SMTLIB2_OBJCP_DECLHANDLER(extract);
SMTLIB2_OBJCP_DECLHANDLER(repeat);
SMTLIB2_OBJCP_DECLHANDLER(zero_extend);
SMTLIB2_OBJCP_DECLHANDLER(sign_extend);
SMTLIB2_OBJCP_DECLHANDLER(rotate_left);
SMTLIB2_OBJCP_DECLHANDLER(rotate_right);

#define SMTLIB2_OBJCP_SETHANDLER(tp, s, name) \
    smtlib2_term_parser_set_handler(tp, s, smtlib2_objcp_parser_mk_ ## name)


typedef struct smtlib2_objcp_parametric_sort {
    char *name_;
    smtlib2_vector *params_;
} smtlib2_objcp_parametric_sort;

static smtlib2_objcp_parametric_sort *smtlib2_objcp_parametric_sort_new(
                                         const char *n, smtlib2_vector *params);
static void smtlib2_objcp_parametric_sort_delete(
                                              smtlib2_objcp_parametric_sort *s);
static uint32_t smtlib2_objcp_parametric_sort_hashfun(intptr_t s);
static bool smtlib2_objcp_parametric_sort_eqfun(intptr_t s1, intptr_t s2);


smtlib2_objcp_parser *smtlib2_objcp_parser_new(void)
{
    smtlib2_objcp_parser *ret =
        (smtlib2_objcp_parser *)malloc(sizeof(smtlib2_objcp_parser));
    smtlib2_parser_interface *pi;
    smtlib2_term_parser *tp;
   
    objcpgw = [OBJCPGateway initOBJCPGateway];
   
    ret->ctx_ = [objcpgw objcp_mk_context];
    smtlib2_abstract_parser_init((smtlib2_abstract_parser *)ret,
                                 (smtlib2_context)ret);
    ret->sorts_ = smtlib2_hashtable_new(smtlib2_objcp_parametric_sort_hashfun,
                                        smtlib2_objcp_parametric_sort_eqfun);
    ret->parametric_sorts_ = smtlib2_hashtable_new(smtlib2_hashfun_str,
                                                   smtlib2_eqfun_str);
    ret->next_sort_idx_ = 1;
    ret->numbers_ = smtlib2_hashtable_new(NULL, NULL);
    ret->defines_ = smtlib2_vector_new();
    ret->defines_sorts_ = smtlib2_vector_new();
    ret->logics_arith_only_ = smtlib2_hashtable_new(smtlib2_hashfun_str,
                                                    smtlib2_eqfun_str);
    smtlib2_hashtable_set(ret->logics_arith_only_, (intptr_t)"QF_LRA", 1);
    smtlib2_hashtable_set(ret->logics_arith_only_, (intptr_t)"QF_LIA", 1);
    smtlib2_hashtable_set(ret->logics_arith_only_, (intptr_t)"QF_RDL", 1);
    smtlib2_hashtable_set(ret->logics_arith_only_, (intptr_t)"QF_IDL", 1);
    ret->named_terms_ = smtlib2_hashtable_new(smtlib2_hashfun_str,
                                              smtlib2_eqfun_str);
    ret->term_names_ = smtlib2_hashtable_new(NULL, NULL);
    ret->assertion_ids_ = smtlib2_hashtable_new(NULL, NULL);
    ret->names_ = smtlib2_vector_new();

    /* initialize the term parser and override virtual methods */
    pi = SMTLIB2_PARSER_INTERFACE(ret);
    pi->set_logic = smtlib2_objcp_parser_set_logic;
    pi->declare_sort = smtlib2_objcp_parser_declare_sort;
    pi->declare_function = smtlib2_objcp_parser_declare_function;
    pi->define_function = smtlib2_objcp_parser_define_function;
    pi->push = smtlib2_objcp_parser_push;
    pi->pop = smtlib2_objcp_parser_pop;
    pi->assert_formula = smtlib2_objcp_parser_assert_formula;
    pi->check_sat = smtlib2_objcp_parser_check_sat;
    pi->annotate_term = smtlib2_objcp_parser_annotate_term;
    pi->set_int_option = smtlib2_objcp_parser_set_int_option;
    pi->get_unsat_core = smtlib2_objcp_parser_get_unsat_core;
    pi->get_assignment = smtlib2_objcp_parser_get_assignment;
    pi->get_value = smtlib2_objcp_parser_get_value;
    pi->make_sort = smtlib2_objcp_parser_make_sort;
    pi->make_function_sort = smtlib2_objcp_parser_make_function_sort;
    pi->make_parametric_sort = smtlib2_objcp_parser_make_parametric_sort;
    pi->define_sort = smtlib2_objcp_parser_define_sort;

    tp = ((smtlib2_abstract_parser *)ret)->termparser_;
    smtlib2_term_parser_set_function_handler(tp,
                                             smtlib2_objcp_parser_mk_function);
    smtlib2_term_parser_set_number_handler(tp,
                                           smtlib2_objcp_parser_mk_number);
    
    SMTLIB2_OBJCP_SETHANDLER(tp, "and", and);
    SMTLIB2_OBJCP_SETHANDLER(tp, "or", or);
    SMTLIB2_OBJCP_SETHANDLER(tp, "not", not);
    SMTLIB2_OBJCP_SETHANDLER(tp, "=>", implies);
    SMTLIB2_OBJCP_SETHANDLER(tp, "=", eq);
    SMTLIB2_OBJCP_SETHANDLER(tp, "+", plus);
    SMTLIB2_OBJCP_SETHANDLER(tp, "*", times);
    SMTLIB2_OBJCP_SETHANDLER(tp, "-", minus);
    SMTLIB2_OBJCP_SETHANDLER(tp, "<=", leq);
    SMTLIB2_OBJCP_SETHANDLER(tp, "<", lt);
    SMTLIB2_OBJCP_SETHANDLER(tp, ">=", geq);
    SMTLIB2_OBJCP_SETHANDLER(tp, ">", gt);
    SMTLIB2_OBJCP_SETHANDLER(tp, "ite", ite);
    SMTLIB2_OBJCP_SETHANDLER(tp, "/", divide);
    SMTLIB2_OBJCP_SETHANDLER(tp, "distinct", distinct);
    SMTLIB2_OBJCP_SETHANDLER(tp, "xor", xor);
    SMTLIB2_OBJCP_SETHANDLER(tp, "nand", nand);
    SMTLIB2_OBJCP_SETHANDLER(tp, "to_real", to_real);

    SMTLIB2_OBJCP_SETHANDLER(tp, "concat", concat);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvnot", bvnot);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvand", bvand);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvnand", bvnand);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvor", bvor);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvnor", bvnor);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvxor", bvxor);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvxnor", bvxnor);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvult", bvult);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvslt", bvslt);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvule", bvule);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsle", bvsle);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvugt", bvugt);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsgt", bvsgt);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvuge", bvuge);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsge", bvsge);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvcomp", bvcomp);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvneg", bvneg);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvadd", bvadd);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsub", bvsub);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvmul", bvmul);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvudiv", bvudiv);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsdiv", bvsdiv);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsmod", bvsmod);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvurem", bvurem);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvsrem", bvsrem);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvshl", bvshl);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvlshr", bvlshr);
    SMTLIB2_OBJCP_SETHANDLER(tp, "bvashr", bvashr);
    SMTLIB2_OBJCP_SETHANDLER(tp, "extract", extract);
    SMTLIB2_OBJCP_SETHANDLER(tp, "repeat", repeat);
    SMTLIB2_OBJCP_SETHANDLER(tp, "zero_extend", zero_extend);
    SMTLIB2_OBJCP_SETHANDLER(tp, "sign_extend", sign_extend);
    SMTLIB2_OBJCP_SETHANDLER(tp, "rotate_left", rotate_left);
    SMTLIB2_OBJCP_SETHANDLER(tp, "rotate_right", rotate_right);
    
    /* the built-in sorts */
    smtlib2_hashtable_set(ret->sorts_,
                          (intptr_t)smtlib2_objcp_parametric_sort_new(
                              "Bool", NULL),
                          (intptr_t)[objcpgw objcp_mk_type:ret->ctx_ withName: "bool"]);
      smtlib2_hashtable_set(ret->sorts_,
                          (intptr_t)smtlib2_objcp_parametric_sort_new(
                              "Int", NULL),
                          (intptr_t)[objcpgw objcp_mk_type:ret->ctx_ withName:"int"]);
    smtlib2_hashtable_set(ret->sorts_,
                          (intptr_t)smtlib2_objcp_parametric_sort_new(
                              "Real", NULL),
                          (intptr_t)[objcpgw objcp_mk_type:ret->ctx_ withName:"real"]);
   
    return ret;
}

#define YCTX(p) (((smtlib2_objcp_parser *)(p))->ctx_)


void smtlib2_objcp_parser_delete(smtlib2_objcp_parser *p)
{
    size_t i;
    smtlib2_vector_delete(p->names_);
    smtlib2_hashtable_delete(p->assertion_ids_, NULL, NULL);
    smtlib2_hashtable_delete(p->named_terms_, (smtlib2_freefun)NULL, NULL);
    smtlib2_hashtable_delete(p->term_names_, NULL, NULL);
    smtlib2_hashtable_delete(p->logics_arith_only_, NULL, NULL);
    smtlib2_vector_delete(p->defines_sorts_);
    for (i = 0; i < smtlib2_vector_size(p->defines_); ++i) {
        char *s = (char *)smtlib2_vector_at(p->defines_, i);
        if (s) free(s);
    }
    smtlib2_vector_delete(p->defines_);
    smtlib2_hashtable_delete(p->numbers_, NULL, (smtlib2_freefun)free);
    smtlib2_hashtable_delete(p->parametric_sorts_, NULL, NULL);
    smtlib2_hashtable_delete(
        p->sorts_, (smtlib2_freefun)smtlib2_objcp_parametric_sort_delete, NULL);
    smtlib2_abstract_parser_deinit(&(p->parent_));
   [objcpgw objcp_del_context:p->ctx_];
    free(p);
}


static void smtlib2_objcp_parser_set_logic(smtlib2_parser_interface *p,
                                           const char *logic)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    smtlib2_abstract_parser_set_logic(p, logic);
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        intptr_t v;
        if (smtlib2_hashtable_find(yp->logics_arith_only_,
                                   (intptr_t)logic, &v)) {
           [objcpgw objcp_set_arith_only:true];
        }
    }
}


static void smtlib2_objcp_parser_declare_sort(smtlib2_parser_interface *p,
                                              const char *sortname,
                                              int arity)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;
    
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        objcp_type tp;
        char s[256];
        smtlib2_objcp_parametric_sort *n;
        sprintf(s, "ytp_%d", yp->next_sort_idx_++);
        ap->response_ = SMTLIB2_RESPONSE_SUCCESS;
       tp = [objcpgw objcp_mk_type:yp->ctx_ withName: s];
        n = smtlib2_objcp_parametric_sort_new(sortname, NULL);
        smtlib2_hashtable_set(yp->sorts_, (intptr_t)n, (intptr_t)tp);
        if (smtlib2_vector_size(yp->defines_sorts_) > 0) {
            smtlib2_vector_push(yp->defines_sorts_, (intptr_t)n);
        }
        if (arity > 0) {
            smtlib2_hashtable_set(yp->parametric_sorts_,
                                  (intptr_t)n->name_, (intptr_t)arity);
        }
    }
}


static void smtlib2_objcp_parser_define_sort(smtlib2_parser_interface *p,
                                             const char *sortname,
                                             smtlib2_vector *params,
                                             smtlib2_sort sort)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;
    
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (params != NULL) {
            ap->response_ = SMTLIB2_RESPONSE_ERROR;
            ap->errmsg_ =
                smtlib2_strdup("define-sort with parameters unsupported");
        } else {
            smtlib2_objcp_parametric_sort *ps =
                smtlib2_objcp_parametric_sort_new(sortname, NULL);
            intptr_t tp;
            if (smtlib2_hashtable_find(yp->sorts_, (intptr_t)ps, &tp)) {
                ap->response_ = SMTLIB2_RESPONSE_ERROR;
                ap->errmsg_ = smtlib2_sprintf(
                    "sort `%s' already declared or defined", sortname);
                smtlib2_objcp_parametric_sort_delete(ps);
            } else {
                smtlib2_hashtable_set(yp->sorts_, (intptr_t)ps, (intptr_t)sort);
                if (smtlib2_vector_size(yp->defines_sorts_) > 0) {
                    smtlib2_vector_push(yp->defines_sorts_, (intptr_t)ps);
                }
            }
        }
    }
}


static void smtlib2_objcp_parser_declare_function(smtlib2_parser_interface *p,
                                                  const char *name,
                                                  smtlib2_sort sort)
{
//   fprintf(stdout, "Declaring function\n");
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;
    
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
       objcp_var_decl d = [objcpgw objcp_mk_var_decl:yp->ctx_ withName:(char *)name andType:(objcp_type)sort];
        if (d) {
            ap->response_ = SMTLIB2_RESPONSE_SUCCESS;
        } else {
            ap->response_ = SMTLIB2_RESPONSE_ERROR;
            ap->errmsg_ = smtlib2_sprintf(
                "error declaring function `%s'", name);
        }
    }
}


static void smtlib2_objcp_parser_define_function(smtlib2_parser_interface *p,
                                                 const char *name,
                                                 smtlib2_vector *params,
                                                 smtlib2_sort sort,
                                                 smtlib2_term term)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;
    
    smtlib2_abstract_parser_define_function(p, name, params, sort, term);

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR &&
        smtlib2_vector_size(yp->defines_) > 0) {
        smtlib2_term_parser *tp = ap->termparser_;
        intptr_t k;
        if (smtlib2_hashtable_find_key(tp->bindings_, (intptr_t)name, &k)) {
            smtlib2_vector_push(yp->defines_, k);
        }
    }
}


static smtlib2_sort smtlib2_objcp_parser_make_sort(smtlib2_parser_interface *p,
                                                   const char *sortname,
                                                   smtlib2_vector *index)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;
    
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (index != NULL) {
            if (strcmp(sortname, "BitVec") == 0 &&
                smtlib2_vector_size(index) == 1) {
                int width = (int)smtlib2_vector_at(index, 0);
               objcp_type bv = [objcpgw objcp_mk_bitvector_type:yp->ctx_ withSize: width];
                if (!bv) {
                    ap->response_ = SMTLIB2_RESPONSE_ERROR;
                    ap->errmsg_ = smtlib2_sprintf(
                        "error creating bit-vector sort of size %d", width);
                }
                return (smtlib2_sort)bv;
            } else {
                ap->response_ = SMTLIB2_RESPONSE_ERROR;
                ap->errmsg_ = smtlib2_sprintf(
                    "unsupported indexed sort `%s', index size %d", sortname,
                    smtlib2_vector_size(index));
                return NULL;
            }
        } else {
            intptr_t v;
            smtlib2_sort ret = NULL;
            smtlib2_objcp_parametric_sort tmp = { (char *)sortname, NULL };
            ap->response_ = SMTLIB2_RESPONSE_SUCCESS;
            if (smtlib2_hashtable_find(yp->sorts_, (intptr_t)&tmp, &v)) {
                ret = (smtlib2_sort)v;
            } else {
                ap->response_ = SMTLIB2_RESPONSE_ERROR;
                ap->errmsg_ = smtlib2_sprintf("unknown sort `%s'", sortname);
            }
            return ret;
        }
    } else {
        return NULL;
    }
}


static smtlib2_sort smtlib2_objcp_parser_make_function_sort(
                                                    smtlib2_parser_interface *p,
                                                    smtlib2_vector *tps)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    smtlib2_sort ret = NULL;
   NSLog(@"Make function sort called.");
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        objcp_type *domain;
        objcp_type range;
        objcp_type tp;
        unsigned long domain_size;

        domain_size = smtlib2_vector_size(tps)-1;
        domain = (objcp_type *)&(smtlib2_vector_at(tps, 0));
        range = (objcp_type)smtlib2_vector_last(tps);

       tp = [objcpgw objcp_mk_function_type:yp->ctx_ withDom:domain withDomSize:domain_size andRange:range];
        ret = (smtlib2_sort)tp;
    }

    return ret;
}


static smtlib2_sort smtlib2_objcp_parser_make_parametric_sort(
    smtlib2_parser_interface *p, const char *name, smtlib2_vector *tps)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    smtlib2_sort ret = NULL;
    
    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        size_t n1 = smtlib2_vector_size(tps);
        intptr_t n2;

        if (!smtlib2_hashtable_find(yp->parametric_sorts_,
                                    (intptr_t)name, &n2) || n1 != (size_t)n2) {
            ap->response_ = SMTLIB2_RESPONSE_ERROR;
            ap->errmsg_ = smtlib2_sprintf("wrong number of arguments for "
                                          "parametric sort `%s'", name);
        } else {
            smtlib2_objcp_parametric_sort tmp = { (char *)name, tps };
            if (smtlib2_hashtable_find(yp->sorts_, (intptr_t)&tmp, &n2)) {
                /* sort already there */
                ret = (smtlib2_sort)n2;
            } else {
                /* create a new instance of this parametric sort */
                objcp_type tp;
                char s[256];
                smtlib2_objcp_parametric_sort *ps =
                    smtlib2_objcp_parametric_sort_new(name, tps);
                sprintf(s, "ytp_%d", yp->next_sort_idx_++);
               tp = [objcpgw objcp_mk_type:yp->ctx_ withName:s];
                smtlib2_hashtable_set(yp->sorts_, (intptr_t)ps, (intptr_t)tp);
                if (smtlib2_vector_size(yp->defines_sorts_) > 0) {
                    smtlib2_vector_push(yp->defines_sorts_, (intptr_t)ps);
                }
                ret = (smtlib2_sort)tp;
            }
        }
    }
    return ret;
}


static void smtlib2_objcp_parser_push(smtlib2_parser_interface *p, int n)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        while (n-- > 0) {
            smtlib2_vector_push(yp->defines_, (intptr_t)NULL);
            smtlib2_vector_push(yp->defines_sorts_, (intptr_t)NULL);
            smtlib2_vector_push(yp->names_, (intptr_t)NULL);
           [objcpgw objcp_push:yp->ctx_];
        }
        ap->response_ = SMTLIB2_RESPONSE_SUCCESS;
    }
}


static void smtlib2_objcp_parser_pop(smtlib2_parser_interface *p, int n)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        smtlib2_term_parser *tp = ap->termparser_;
        while (n-- > 0) {
            char *def = (char *)smtlib2_vector_last(yp->defines_);
            smtlib2_objcp_parametric_sort *ps = NULL;
            
            while (def != NULL) {
                smtlib2_term_parser_undefine_binding(tp, def);
                smtlib2_vector_pop(yp->defines_);
                def = (char *)smtlib2_vector_last(yp->defines_);
            }
            smtlib2_vector_pop(yp->defines_);
            
            ps = (smtlib2_objcp_parametric_sort *)smtlib2_vector_last(
                yp->defines_sorts_);
            while (ps != NULL) {
                smtlib2_hashtable_erase(yp->sorts_, (intptr_t)ps);
                smtlib2_vector_pop(yp->defines_sorts_);
                smtlib2_objcp_parametric_sort_delete(ps);
                ps = (smtlib2_objcp_parametric_sort *)smtlib2_vector_last(
                    yp->defines_sorts_);
            }
            smtlib2_vector_pop(yp->defines_sorts_);

            def = (char *)smtlib2_vector_last(yp->names_);
            while (def != NULL) {
                intptr_t t = smtlib2_hashtable_get(yp->named_terms_,
                                                   (intptr_t)def);
                smtlib2_hashtable_erase(yp->named_terms_, (intptr_t)def);
                if (t) {
                    smtlib2_hashtable_erase(yp->term_names_, t);
                }
                
                smtlib2_vector_pop(yp->names_);
                free(def);
                def = (char *)smtlib2_vector_last(yp->names_);
            }
            smtlib2_vector_pop(yp->names_);
            
           [objcpgw objcp_pop:yp->ctx_];
        }
        ap->response_ = SMTLIB2_RESPONSE_SUCCESS;
    }
}


static void smtlib2_objcp_parser_assert_formula(smtlib2_parser_interface *p,
                                                smtlib2_term term)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (yp->produce_unsat_cores_) {
            intptr_t n;
            if (smtlib2_hashtable_find(yp->term_names_, (intptr_t)term, &n)) {
               assertion_id aid = [objcpgw objcp_assert_retractable:yp->ctx_ withExpr:(objcp_expr)term];
                smtlib2_hashtable_set(yp->assertion_ids_, aid, n);
            } else {
               [objcpgw  objcp_assert:yp->ctx_ withExpr: (objcp_expr)term];
            }
        } else {
           [objcpgw objcp_assert:yp->ctx_ withExpr:(objcp_expr)term];
        }
        ap->response_ = SMTLIB2_RESPONSE_SUCCESS;
    }
}


static void smtlib2_objcp_parser_check_sat(smtlib2_parser_interface *p)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
       lbool s = [objcpgw objcp_check:yp->ctx_];
        ap->response_ = SMTLIB2_RESPONSE_STATUS;
        switch (s) {
        case false: ap->status_ = SMTLIB2_STATUS_UNSAT; break;
        case true: ap->status_ = SMTLIB2_STATUS_SAT; break;
        default: ap->status_ = SMTLIB2_STATUS_UNKNOWN;
        }
    }
}


static void smtlib2_objcp_parser_annotate_term(smtlib2_parser_interface *p,
                                               smtlib2_term term,
                                               smtlib2_vector *annotations)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        size_t i;
        for (i = 0; i < smtlib2_vector_size(annotations); ++i) {
            const char **an = (const char **)smtlib2_vector_at(annotations, i);
            if (strcmp(an[0], ":named") == 0) {
                smtlib2_term t =
                    (smtlib2_term)smtlib2_hashtable_get(yp->named_terms_,
                                                        (intptr_t)an[1]);
                if (t != NULL && t != term) {
                    ap->response_ = SMTLIB2_RESPONSE_ERROR;
                    ap->errmsg_ = smtlib2_sprintf("annotation :named `%s' is "
                                                  "already in use", ap[1]);
                } else {
                    char *n = smtlib2_strdup(an[1]);
                    smtlib2_vector_push(yp->names_, (intptr_t)n);
                    smtlib2_hashtable_set(yp->named_terms_, (intptr_t)n,
                                          (intptr_t)term);
                    smtlib2_hashtable_set(yp->term_names_, (intptr_t)term,
                                          (intptr_t)n);
                }
            }
        }
    }
}


static void smtlib2_objcp_parser_set_int_option(smtlib2_parser_interface *p,
                                                const char *keyword,
                                                int value)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (strcmp(keyword, ":produce-unsat-cores") == 0) {
            yp->produce_unsat_cores_ = value;
        } else if (strcmp(keyword, ":produce-assignments") == 0) {
            yp->produce_assignments_ = value;
        } else if (strcmp(keyword, ":produce-models") == 0) {
            yp->produce_models_ = value;
        } else {
            smtlib2_abstract_parser_set_int_option(p, keyword, value);
        }
    }
}


static void smtlib2_objcp_parser_get_assignment(smtlib2_parser_interface *p)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (yp->produce_assignments_) {
            size_t i;
            id<ORModel> m;

            //m = objcp_get_model(yp->ctx_);
           m = [objcpgw getModel];
            if (!m) {
                ap->response_ = SMTLIB2_RESPONSE_ERROR;
                ap->errmsg_ = smtlib2_strdup("error computing assignment");
                return;
            }
            
            ap->response_ = SMTLIB2_RESPONSE_MODEL;

            for (i = 0; i < smtlib2_vector_size(yp->names_); ++i) {
                intptr_t n = smtlib2_vector_at(yp->names_, i);
                if (n) {
                    intptr_t t;
                    if (smtlib2_hashtable_find(yp->named_terms_, n, &t)) {
                       lbool v = [objcpgw objcp_evaluate_in_model:yp->ctx_ withExpr:(objcp_expr)t];
                        char *vv = NULL;
                        if (v == l_true) {
                            vv = smtlib2_strdup("true");
                        } else if (v == l_false) {
                            vv = smtlib2_strdup("false");
                        }
                        if (vv) {
                            char *nn = smtlib2_strdup((char *)n);
                            smtlib2_vector_push(ap->response_data_,
                                                (intptr_t)nn);
                            smtlib2_vector_push(ap->response_data_,
                                                (intptr_t)vv);
                        }
                    } else {
                        ap->response_ = SMTLIB2_RESPONSE_ERROR;
                        ap->errmsg_ =
                            smtlib2_strdup("error computing assignment");
                        return;
                    }
                }
            }
        } else {
            ap->response_ = SMTLIB2_RESPONSE_ERROR;
            ap->errmsg_ = smtlib2_strdup(":produce-assignments option not set");
        }
    }    
}


static void smtlib2_objcp_parser_get_value(smtlib2_parser_interface *p,
                                           smtlib2_vector *terms)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (yp->produce_models_) {
            size_t i;
            id<ORModel> m;
            smtlib2_charbuf *buf;
            mpq_t ratval;

            //m = objcp_get_model(yp->ctx_);
           m= [objcpgw getModel];
            if (!m) {
                ap->response_ = SMTLIB2_RESPONSE_ERROR;
                ap->errmsg_ = smtlib2_strdup("error computing model");
                return;
            }

            buf = smtlib2_charbuf_new();
            smtlib2_charbuf_push_str(buf, "(.internal-parse-terms (");
            for (i = 0; i < smtlib2_vector_size(terms); ++i) {
                char *t = (char *)smtlib2_vector_at(terms, i);
                smtlib2_charbuf_push_str(buf, t);
                smtlib2_charbuf_push(buf, ' ');
            }
            smtlib2_charbuf_push_str(buf, "))");
            {
                smtlib2_scanner *scanner;
                smtlib2_sstream *stream;

                ap->internal_parsed_terms_enabled_ = true;
                
                stream = smtlib2_sstream_new(buf);
                scanner = smtlib2_scanner_new((smtlib2_stream *)stream);
                
                smtlib2_parse(scanner, p);

                smtlib2_scanner_delete(scanner);
                smtlib2_sstream_delete(stream);
                
                ap->internal_parsed_terms_enabled_ = false;
            }
            if (ap->response_ == SMTLIB2_RESPONSE_ERROR) {
                return;
            }
            
            ap->response_ = SMTLIB2_RESPONSE_MODEL;
            mpq_init(ratval);

            for (i = 0; i < smtlib2_vector_size(terms); ++i) {
                intptr_t n = smtlib2_vector_at(terms, i);
                intptr_t t = smtlib2_vector_at(ap->internal_parsed_terms_, i);

                char *vv = NULL;
               lbool v = [objcpgw objcp_evaluate_in_model:m withExpr:(objcp_expr)t];
                if (v == l_true) {
                    vv = smtlib2_strdup("true");
                } else if (v == l_false) {
                    vv = smtlib2_strdup("false");
                }
                if (!vv) {
                   objcp_var_decl d = [objcpgw objcp_get_var_decl:yp->ctx_ withExpr:(objcp_expr)t];
                    /* get the model value for this variable */
                   if (![objcpgw objcp_get_mpq_value:m withDecl:d andRV:ratval]) {
                       lbool v = [objcpgw objcp_get_value:m withVar:d];
                        if (v == l_true) {
                            vv = smtlib2_strdup("true");
                        } else if (v == l_false) {
                            vv = smtlib2_strdup("false");
                        }
                    } else {
                        char *rn = mpz_get_str(NULL, 10, mpq_numref(ratval));
                        if (mpz_cmp_ui(mpq_denref(ratval), 1) == 0) {
                            if (mpq_sgn(ratval) < 0) {
                                vv = smtlib2_sprintf("(- %s)", rn+1);
                            } else {
                                vv = smtlib2_strdup(rn);
                            }                            
                        } else {
                            char *rd = mpz_get_str(NULL, 10,
                                                   mpq_denref(ratval));
                            if (mpq_sgn(ratval) < 0) {
                                vv = smtlib2_sprintf("(/ (- %s) %s)", rn+1, rd);
                            } else {
                                vv = smtlib2_sprintf("(/ %s %s)", rn, rd);
                            }
                            free(rd);
                        }
                        free(rn);
                    }
                }
                if (vv) {
                    char *nn = smtlib2_strdup((char *)n);
                    smtlib2_vector_push(ap->response_data_, (intptr_t)nn);
                    smtlib2_vector_push(ap->response_data_, (intptr_t)vv);
                } else {
                    ap->response_ = SMTLIB2_RESPONSE_ERROR;
                    ap->errmsg_ =
                        smtlib2_strdup("error computing model");
                    break;
                }
            }
            mpq_clear(ratval);
        } else {
            ap->response_ = SMTLIB2_RESPONSE_ERROR;
            ap->errmsg_ = smtlib2_strdup(":produce-models option not set");
        }
    }    
}


static void smtlib2_objcp_parser_get_unsat_core(smtlib2_parser_interface *p)
{
    smtlib2_objcp_parser *yp = (smtlib2_objcp_parser *)p;
    smtlib2_abstract_parser *ap = (smtlib2_abstract_parser *)p;

    if (ap->response_ != SMTLIB2_RESPONSE_ERROR) {
        if (yp->produce_unsat_cores_) {
            unsigned int n;
            assertion_id *core;
           n = [objcpgw objcp_get_unsat_core_size:yp->ctx_];
            if (!n) {
                ap->response_ = SMTLIB2_RESPONSE_ERROR;
                ap->errmsg_ = smtlib2_strdup("error computing unsat core");
            } else {
                unsigned int i;
                core = (assertion_id *)malloc(sizeof(assertion_id) * n);
               [objcpgw objcp_get_unsat_core:yp->ctx_ withId:core];

                ap->response_ = SMTLIB2_RESPONSE_UNSATCORE;
                
                for (i = 0; i < n; ++i) {
                    intptr_t n;
                    if (smtlib2_hashtable_find(yp->assertion_ids_,
                                               (intptr_t)core[i], &n)) {
                        smtlib2_vector_push(ap->response_data_, n);
                    } else {
                        ap->response_ = SMTLIB2_RESPONSE_ERROR;
                        ap->errmsg_ =
                            smtlib2_strdup("error computing unsat core");
                        break;
                    }
                }
                free(core);
            }
        } else {
            ap->response_ = SMTLIB2_RESPONSE_ERROR;
            ap->errmsg_ = smtlib2_strdup(":produce-unsat-cores option not set");
        }
    }
}


static smtlib2_term smtlib2_objcp_parser_mk_function(smtlib2_context ctx,
                                                     const char *symbol,
                                                     smtlib2_sort sort,
                                                     smtlib2_vector *index,
                                                     smtlib2_vector *args)
{
    objcp_context yctx = YCTX(ctx);
    if (index) {
        return NULL;
    }
    if (args) {
       objcp_var_decl d = [objcpgw objcp_get_var_decl_from_name:yctx withName:symbol];
        if (d) {
           objcp_expr f = [objcpgw objcp_mk_var_from_decl:yctx withDecl: d];
            if (f) {
               return [objcpgw objcp_mk_app:yctx
                                    withFun: f
                                   withArgs:(objcp_context *)&(smtlib2_vector_at(args, 0))
                                 andNumArgs:smtlib2_vector_size(args)];
            } else {
                return NULL;
            }
        } else {
            return NULL;
        }
    } else {
        if (strcmp(symbol, "true") == 0) {
           return (smtlib2_term)[objcpgw objcp_mk_true:yctx];
        } else if (strcmp(symbol, "false") == 0) {
           return (smtlib2_term)[objcpgw objcp_mk_false:yctx];
        } else {
            /* TODO: typecheck */
           objcp_var_decl d = [objcpgw objcp_get_var_decl_from_name:yctx
                                                           withName:(char *)symbol];
            if (d) {
               return [objcpgw objcp_mk_var_from_decl:yctx withDecl:d];
            } else {
                return NULL;
            }
        }
    }
}


static smtlib2_term smtlib2_objcp_parser_mk_number(smtlib2_context ctx,
                                                   const char *rep,
                                                   unsigned int width,
                                                   unsigned int base)
{
    smtlib2_term ret;
    intptr_t v;
    if (width != 0) {
        mpz_t tmp;
        int i;
        int *bits = malloc(sizeof(int) * width);
        smtlib2_term ret = NULL;
        mpz_init(tmp);
        mpz_set_str(tmp, rep, base);
        for (i = 0; i < width; ++i) {
            bits[i] = mpz_tstbit(tmp, i);
        }
        mpz_clear(tmp);
        ret = [objcpgw objcp_mk_bv_constant_from_array:YCTX(ctx) withSize:width fromArray:bits];
        free(bits);
        return ret;
    } else if (base != 10) {
        return NULL;
    }
   ret = (smtlib2_term)[objcpgw objcp_mk_num_from_string:YCTX(ctx) withString:(char *)rep];
    if (!smtlib2_hashtable_find(((smtlib2_objcp_parser *)ctx)->numbers_,
                                (intptr_t)ret, &v)) {
        smtlib2_hashtable_set(((smtlib2_objcp_parser *)ctx)->numbers_,
                              (intptr_t)ret, (intptr_t)smtlib2_strdup(rep));
    }
    return ret;
}

SMTLIB2_OBJCP_DECLHANDLER(and) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_and:YCTX(ctx)
                       withArgs:(objcp_expr *)&(smtlib2_vector_at(args, 0))
                     andNumArgs:smtlib2_vector_size(args)];
}


SMTLIB2_OBJCP_DECLHANDLER(or) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_or:YCTX(ctx)
                      withArgs:(objcp_expr *)&(smtlib2_vector_at(args, 0))
                    andNumArgs:smtlib2_vector_size(args)];
}


SMTLIB2_OBJCP_DECLHANDLER(not) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_not:YCTX(ctx)
                       withArg:(objcp_expr)smtlib2_vector_at(args, 0)];
}

SMTLIB2_OBJCP_DECLHANDLER(implies) { return NULL; /* TODO */ }
//{
//    objcp_context yctx = YCTX(ctx);
//    objcp_expr ret = (objcp_expr)smtlib2_vector_last(args);
//    long i;
//    
//    for (i = smtlib2_vector_size(args)-2; i >= 0; --i) {
//        objcp_expr a = (objcp_expr)smtlib2_vector_at(args, i);
//       objcp_expr aa[2] = { [objcpgw objcp_mk_not:yctx withArg:a], ret };
//       ret = [objcpgw objcp_mk_or:yctx withArg:aa andLen:2];
//    }
//    return ret;
//    
//}


SMTLIB2_OBJCP_DECLHANDLER(eq) //{ return NULL; /* TODO */ }
{
   id<ORBitVar> ret = [objcpgw objcp_mk_eq:YCTX(ctx)
                           withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                            andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
   
   objcp_context yctx = YCTX(ctx);
//   id<ORBitVar> ret = [objcpgw objcp_mk_eq:yctx withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                                  andArg:(objcp_expr)smtlib2_vector_at(args, 1)];

    size_t i;
    
    for (i = 2; i < smtlib2_vector_size(args); ++i) {
        objcp_expr prev = (objcp_expr)smtlib2_vector_at(args, i-1);
        objcp_expr cur = (objcp_expr)smtlib2_vector_at(args, i);
       objcp_expr aa[2] = { ret, [objcpgw objcp_mk_eq:yctx withArg:prev andArg:cur] };
       ret = [objcpgw objcp_mk_and:yctx withArgs:aa andNumArgs:2];
    }
    return ret;
}


SMTLIB2_OBJCP_DECLHANDLER(plus) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_sum:YCTX(ctx)
//                        withArgs:(objcp_expr *)&(smtlib2_vector_at(args, 0))
//                      andNumArgs:smtlib2_vector_size(args)];
//}


SMTLIB2_OBJCP_DECLHANDLER(times) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_mul:YCTX(ctx)
//                withArgs:(objcp_expr *)&(smtlib2_vector_at(args, 0))
//                 andNumArgs:smtlib2_vector_size(args)];
//}


SMTLIB2_OBJCP_DECLHANDLER(minus) { return NULL; /* TODO */ }
//{
//    objcp_expr *aa = (objcp_expr *)smtlib2_vector_array(args);
//    if (smtlib2_vector_size(args) == 1) {
//       objcp_expr a0[2] = { [objcpgw objcp_mk_num:YCTX(ctx) -1], aa[0] };
//       return [objcpgw objcp_mk_mul:YCTX(ctx) withArg:a0 andNumArgs:2];
//    }
//   return [objcpgw objcp_mk_sub:YCTX(ctx) withArgs:aa andNumArgs:smtlib2_vector_size(args)];
//}


SMTLIB2_OBJCP_DECLHANDLER(leq) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_le:YCTX(ctx)
//                        withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                         andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


SMTLIB2_OBJCP_DECLHANDLER(lt) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_lt:YCTX(ctx)
//                        wihtArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                         andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


SMTLIB2_OBJCP_DECLHANDLER(geq) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_ge:YCTX(ctx)
//                        withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                         andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}
//

SMTLIB2_OBJCP_DECLHANDLER(gt) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_gt:YCTX(ctx)
//                        withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                         andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


/**
 \brief Return an expression representing <tt>(if c t e)</tt>.
 */
SMTLIB2_OBJCP_DECLHANDLER(ite) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_ite:YCTX(ctx)
                       if:(objcp_expr)smtlib2_vector_at(args, 0)
                       then:(objcp_expr)smtlib2_vector_at(args, 1)
                       else:(objcp_expr)smtlib2_vector_at(args, 2)];
}


SMTLIB2_OBJCP_DECLHANDLER(divide) { return NULL; /* TODO */ }
//{
//    smtlib2_objcp_parser *p = (smtlib2_objcp_parser *)ctx;
//    intptr_t v, v2;
//    if (smtlib2_hashtable_find(p->numbers_, smtlib2_vector_at(args, 1), &v)) {
//        objcp_expr e;
//        char *n;
//        if (smtlib2_hashtable_find(p->numbers_,
//                                   smtlib2_vector_at(args, 0), &v2)) {
//            n = smtlib2_sprintf("%s/%s", (const char *)v2, (const char *)v);
//           e = [objcpgw objcp_mk_num_from_string:YCTX(ctx) withLen: n];
//            free(n);
//            return e;
//        } else {
//            n = smtlib2_sprintf("1/%s", (const char *)v);
//        }
//        e = [objcpgw objcp_mk_num_from_string:YCTX(ctx) withLen: n];
//        free(n);
//        if (e) {
//            objcp_expr aa[2] = { e, (objcp_expr)smtlib2_vector_at(args, 0) };
//           return [objcpgw objcp_mk_mul:YCTX(ctx) withExpr:aa andLen:2];
//        } else {
//            return NULL;
//        }
//    } else {
//        return NULL;
//    }
//}


SMTLIB2_OBJCP_DECLHANDLER(distinct) { //return NULL; /* TODO */ }

    objcp_expr ret = NULL;
    size_t i;
    smtlib2_vector *tmp = smtlib2_vector_new();
    
    for (i = 0; i < smtlib2_vector_size(args); ++i) {
        objcp_expr a = (objcp_expr)smtlib2_vector_at(args, i);
        size_t j;
        for (j = i+1; j < smtlib2_vector_size(args); ++j) {
            objcp_expr b = (objcp_expr)smtlib2_vector_at(args, j);
           objcp_expr eq = [objcpgw objcp_mk_diseq:YCTX(ctx)var:a neq:b];
            smtlib2_vector_push(tmp, (intptr_t)eq);
        }
    }
   ret = [objcpgw objcp_mk_and:YCTX(ctx) withArgs:(objcp_expr *)&(smtlib2_vector_at(tmp, 0)) andNumArgs:smtlib2_vector_size(tmp)];
    smtlib2_vector_delete(tmp);
    
    return ret;    
}


SMTLIB2_OBJCP_DECLHANDLER(xor) { return NULL; /* TODO */ }
//{
//    objcp_expr ret = (objcp_expr)smtlib2_vector_at(args, 0);
//    size_t i;
//    
//    for (i = 1; i < smtlib2_vector_size(args); ++i) {
//       ret = [objcpgw objcp_mk_diseq:YCTX(ctx) var:ret neq:(objcp_expr)smtlib2_vector_at(args, i)];
//    }
//    return ret;
//    
//}


SMTLIB2_OBJCP_DECLHANDLER(nand) { return NULL; /* TODO */ }
//{
//   return [objcpgw  objcp_mk_not: YCTX(ctx)
//                             var:[objcpgw objcp_mk_and:YCTX(ctx) var:(objcp_expr *)&(smtlib2_vector_at(args, 0)) and:smtlib2_vector_size(args)]];
//}


SMTLIB2_OBJCP_DECLHANDLER(to_real) { return NULL; /* TODO */ }
//{
//    return (objcp_expr)smtlib2_vector_at(args, 0);
//}


SMTLIB2_OBJCP_DECLHANDLER(concat) //{ return NULL; /* TODO */ }
{
    return [objcpgw objcp_mk_bv_concat:YCTX(ctx)
                               withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvnot)
{
   return [objcpgw objcp_mk_bv_not:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvand)
{
   return [objcpgw objcp_mk_bv_and:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                              andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvnand)
{
   return [objcpgw objcp_mk_bv_not:YCTX(ctx)
                           withArg:[objcpgw objcp_mk_bv_and:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                                                       andArg:(objcp_expr)smtlib2_vector_at(args, 1)]];
}


SMTLIB2_OBJCP_DECLHANDLER(bvor)
{
   return [objcpgw objcp_mk_bv_or:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                             andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvnor)
{
   return [objcpgw objcp_mk_bv_not:YCTX(ctx)
                           withArg:[objcpgw objcp_mk_bv_or:YCTX(ctx)
                                                   withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                                    andArg:(objcp_expr)smtlib2_vector_at(args, 1)]];
}


SMTLIB2_OBJCP_DECLHANDLER(bvxor)
{
   return [objcpgw objcp_mk_bv_xor:YCTX(ctx)
                           withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                            andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvxnor)
{
   return [objcpgw objcp_mk_bv_not:YCTX(ctx)
                           withArg:[objcpgw objcp_mk_bv_xor:YCTX(ctx)
                                                    withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                                     andArg:(objcp_expr)smtlib2_vector_at(args, 1)]];
}


SMTLIB2_OBJCP_DECLHANDLER(bvult) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_bv_lt:YCTX(ctx)
                          x:(objcp_expr)smtlib2_vector_at(args, 0)
                           lt:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvshl) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_bv_shl:YCTX(ctx)
                           withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                            andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}

SMTLIB2_OBJCP_DECLHANDLER(bvlshr) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_bv_shrl:YCTX(ctx)
                           withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                            andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvule) //{ return NULL; /* TODO */ }
{
    return [objcpgw objcp_mk_bv_le:YCTX(ctx)
                           x:(objcp_expr)smtlib2_vector_at(args, 0)
                            le:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvsle) //{ return NULL; /* TODO */ }
{
    return [objcpgw objcp_mk_bv_sle:YCTX(ctx)
                            x:(objcp_expr)smtlib2_vector_at(args, 0)
                             sle:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvugt)  { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_bv_gt:YCTX(ctx)
//                           withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                            andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


SMTLIB2_OBJCP_DECLHANDLER(bvsgt) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_bv_sgt:YCTX(ctx)
//                            withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                             andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


SMTLIB2_OBJCP_DECLHANDLER(bvuge)  { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_bv_ge:YCTX(ctx)
//                           withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                            andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


SMTLIB2_OBJCP_DECLHANDLER(bvsge) { return NULL; /* TODO */ }
//{
//    return [objcpgw objcp_mk_bv_sge:YCTX(ctx)
//                            withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                             andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
//}


SMTLIB2_OBJCP_DECLHANDLER(bvcomp) { return NULL; /* TODO */ }
//{
//   return [objcpgw objcp_mk_ite:YCTX(ctx)
//                        withArg:[objcpgw objcp_mk_eq:YCTX(ctx)
//                                             withArg:(objcp_expr)smtlib2_vector_at(args, 0)
//                                              andArg:(objcp_expr)smtlib2_vector_at(args, 1)
//                                             withOne:[objcpgw objcp_mk_bv_constant:YCTX(ctx) withLen:1 andVal:1]
//                                             andZero:[objcpgw objcp_mk_bv_constant:YCTX(ctx) withLen:1 andVal:0]]];
//}


SMTLIB2_OBJCP_DECLHANDLER(bvneg) //{ return NULL; /* TODO */ }
{
            return [objcpgw objcp_mk_bv_minus:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvadd)
{
    return [objcpgw objcp_mk_bv_add:YCTX(ctx)
                            withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                           andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvsub) //{ return NULL; /* TODO */ }
{
    return [objcpgw objcp_mk_bv_sub:YCTX(ctx)
                            withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                             andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvmul) //{ return NULL; /* TODO */ }
{
    return [objcpgw objcp_mk_bv_mul:YCTX(ctx)
                            withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                             andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}


SMTLIB2_OBJCP_DECLHANDLER(bvudiv) { return NULL; /* TODO */ }
SMTLIB2_OBJCP_DECLHANDLER(bvsdiv) { return NULL; /* TODO */ }
SMTLIB2_OBJCP_DECLHANDLER(bvsmod) { return NULL; /* TODO */ }
SMTLIB2_OBJCP_DECLHANDLER(bvurem) { return NULL; /* TODO */ }
SMTLIB2_OBJCP_DECLHANDLER(bvsrem) { return NULL; /* TODO */ }
SMTLIB2_OBJCP_DECLHANDLER(bvslt)  {// return NULL; /* TODO */ }
   return [objcpgw objcp_mk_bv_slt:YCTX(ctx)
                                 x:(objcp_expr)smtlib2_vector_at(args, 0)
                               slt:(objcp_expr)smtlib2_vector_at(args, 1)];
}
//SMTLIB2_OBJCP_DECLHANDLER(bvlshr) { return NULL; /* TODO */ }
SMTLIB2_OBJCP_DECLHANDLER(bvashr) //{ return NULL; /* TODO */ }
{
   return [objcpgw objcp_mk_bv_shra:YCTX(ctx)
                            withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                             andArg:(objcp_expr)smtlib2_vector_at(args, 1)];
}

SMTLIB2_OBJCP_DECLHANDLER(extract) //{ return NULL; /* TODO */ }
{
    size_t msb = (size_t)smtlib2_vector_at(idx, 0);
    size_t lsb = (size_t)smtlib2_vector_at(idx, 1);
            return [objcpgw objcp_mk_bv_extract:YCTX(ctx) from:msb downTo:lsb in:(objcp_expr)smtlib2_vector_at(args, 0)];
}


SMTLIB2_OBJCP_DECLHANDLER(repeat) { return NULL; /* TODO */ }
//{
//    size_t amount = (size_t)smtlib2_vector_at(idx, 0);
//    objcp_expr t = (objcp_expr)smtlib2_vector_at(args, 0);
//    objcp_expr ret = t;
//    size_t i;
//    for (i = 1; i < amount; ++i) {
//            ret = [objcpgw objcp_mk_bv_concat:YCTX(ctx) withArg:ret andArg:t];
//    }
//    return ret;
//}


SMTLIB2_OBJCP_DECLHANDLER(zero_extend) //{ return NULL; /* TODO */ }
{
    size_t amount = (size_t)smtlib2_vector_at(idx, 0);
//   objcp_expr pad = [objcpgw objcp_mk_bv_constant:YCTX(ctx) extendBy:amount with:0];
            return [objcpgw objcp_mk_bv_zero_extend:YCTX(ctx)
                                       withArg:(objcp_expr)smtlib2_vector_at(args, 0)
                                        andAmount:(ORUInt)amount];
}


SMTLIB2_OBJCP_DECLHANDLER(sign_extend) //{ return NULL; /* TODO */ }
{
    size_t amount = (size_t)smtlib2_vector_at(idx, 0);
   return [objcpgw objcp_mk_bv_sign_extend:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0) andAmount:(ORUInt)amount];
}


SMTLIB2_OBJCP_DECLHANDLER(rotate_left) {
   size_t amount = (size_t)smtlib2_vector_at(idx, 0);
   return [objcpgw objcp_mk_bv_rotl:YCTX(ctx) withArg:(objcp_expr)smtlib2_vector_at(args, 0) andAmount:(ORUInt)amount];
}
SMTLIB2_OBJCP_DECLHANDLER(rotate_right)  { return NULL; /* TODO */ }


/*----------------------------------------------------------------------------*/

static smtlib2_objcp_parametric_sort *smtlib2_objcp_parametric_sort_new(
    const char *name, smtlib2_vector *params)
{
    smtlib2_objcp_parametric_sort *ret =
        (smtlib2_objcp_parametric_sort *)malloc(
            sizeof(smtlib2_objcp_parametric_sort));
    ret->name_ = smtlib2_strdup(name);
    ret->params_ = NULL;
    if (params) {
        ret->params_ = smtlib2_vector_new();
        smtlib2_vector_copy(params, ret->params_);
    }
    return ret;
}


static void smtlib2_objcp_parametric_sort_delete(
    smtlib2_objcp_parametric_sort *s)
{
    if (s->params_) {
        smtlib2_vector_delete(s->params_);
    }
    free(s->name_);
    free(s);
}


static uint32_t smtlib2_objcp_parametric_sort_hashfun(intptr_t s)
{
    smtlib2_objcp_parametric_sort *ps = (smtlib2_objcp_parametric_sort *)s;
    uint32_t ret;
    ret = smtlib2_hashfun_str((intptr_t)ps->name_);
    if (ps->params_) {
        size_t i;
        for (i = 0; i < smtlib2_vector_size(ps->params_); ++i) {
            ret = 5 * ret + (uint32_t)smtlib2_vector_at(ps->params_, i);
        }
    }
    return ret;
}


static bool smtlib2_objcp_parametric_sort_eqfun(intptr_t s1, intptr_t s2)
{
    smtlib2_objcp_parametric_sort *ps1 = (smtlib2_objcp_parametric_sort *)s1;
    smtlib2_objcp_parametric_sort *ps2 = (smtlib2_objcp_parametric_sort *)s2;

    if (ps1 == ps2) {
        return true;
    }
    if ((ps1->params_ == NULL) != (ps2->params_ == NULL)) {
        return false;
    }
    if (strcmp(ps1->name_, ps2->name_) != 0) {
        return false;
    }
    if (ps1->params_) {
        size_t i;
        if (smtlib2_vector_size(ps1->params_) !=
            smtlib2_vector_size(ps2->params_)) {
            return false;
        }
        for (i = 0; i < smtlib2_vector_size(ps1->params_); ++i) {
            if (smtlib2_vector_at(ps1->params_, i) !=
                smtlib2_vector_at(ps2->params_, i)) {
                return false;
            }
        }
    }
    return true;
}

