/* tslint:disable */
/* eslint-disable */
/**
 * Hydra API
 * Specification of the Hydra REST API
 *
 * OpenAPI spec version: 1.0.0
 * 
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen.git
 * Do not edit the class manually.
 */

 /**
 * 
 *
 * @export
 * @interface DeclarativeInput
 */
export interface DeclarativeInput {

    /**
     * The file in `value` which contains the declarative spec file. Relative to the root of `value`.
     *
     * @type {string}
     * @memberof DeclarativeInput
     */
    file?: string;

    /**
     * The type of the declarative input.
     *
     * @type {string}
     * @memberof DeclarativeInput
     */
    type?: string;

    /**
     * The value of the declarative input.
     *
     * @type {string}
     * @memberof DeclarativeInput
     */
    value?: string;
}
