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
 * @interface BuildProduct
 */
export interface BuildProduct {

    /**
     * Size of the produced file
     *
     * @type {number}
     * @memberof BuildProduct
     */
    filesize?: number | null;

    /**
     * if path is a directory, the default file relative to path to be served
     *
     * @type {string}
     * @memberof BuildProduct
     */
    defaultpath?: string;

    /**
     * Types of build product (user defined)
     *
     * @type {string}
     * @memberof BuildProduct
     */
    type?: string;

    /**
     * Name of the file
     *
     * @type {string}
     * @memberof BuildProduct
     */
    name?: string;

    /**
     * the nix store path
     *
     * @type {string}
     * @memberof BuildProduct
     */
    path?: string;

    /**
     * user-specified
     *
     * @type {string}
     * @memberof BuildProduct
     */
    subtype?: string;

    /**
     * sha256 hash of the file
     *
     * @type {string}
     * @memberof BuildProduct
     */
    sha256hash?: string | null;
}