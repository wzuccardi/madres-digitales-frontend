--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9
-- Dumped by pg_dump version 16.4

-- Started on 2025-11-06 23:17:12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 147847)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 6467 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 11 (class 2615 OID 150773)
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 151029)
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 106618)
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- TOC entry 6469 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- TOC entry 4 (class 3079 OID 150761)
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- TOC entry 6470 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- TOC entry 2 (class 3079 OID 149512)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 6471 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 5 (class 3079 OID 150774)
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- TOC entry 6472 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- TOC entry 3 (class 3079 OID 150592)
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- TOC entry 6473 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- TOC entry 1892 (class 1247 OID 148035)
-- Name: alerta_tipo; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.alerta_tipo AS ENUM (
    'SOS',
    'MEDICA',
    'CONTROL',
    'RECORDATORIO',
    'HIPERTENSION',
    'PREECLAMPSIA',
    'DIABETES',
    'SANGRADO',
    'CONTRACCIONES',
    'FALTA_MOVIMIENTO_FETAL'
);


ALTER TYPE public.alerta_tipo OWNER TO postgres;

--
-- TOC entry 1901 (class 1247 OID 148080)
-- Name: categoria_contenido; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.categoria_contenido AS ENUM (
    'NUTRICION',
    'EJERCICIO',
    'CUIDADOS_PRENATALES',
    'PREPARACION_PARTO',
    'LACTANCIA',
    'CUIDADOS_BEBE',
    'SALUD_MENTAL',
    'EMERGENCIAS'
);


ALTER TYPE public.categoria_contenido OWNER TO postgres;

--
-- TOC entry 1904 (class 1247 OID 148098)
-- Name: nivel_dificultad; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.nivel_dificultad AS ENUM (
    'BASICO',
    'INTERMEDIO',
    'AVANZADO'
);


ALTER TYPE public.nivel_dificultad OWNER TO postgres;

--
-- TOC entry 1895 (class 1247 OID 148056)
-- Name: prioridad_nivel; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.prioridad_nivel AS ENUM (
    'BAJA',
    'MEDIA',
    'ALTA',
    'CRITICA'
);


ALTER TYPE public.prioridad_nivel OWNER TO postgres;

--
-- TOC entry 1898 (class 1247 OID 148066)
-- Name: tipo_contenido; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipo_contenido AS ENUM (
    'VIDEO',
    'ARTICULO',
    'INFOGRAFIA',
    'PODCAST',
    'EJERCICIO',
    'RECETA'
);


ALTER TYPE public.tipo_contenido OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 147848)
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 147913)
-- Name: alertas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alertas (
    id text NOT NULL,
    gestante_id text NOT NULL,
    madrina_id text,
    medico_asignado_id text,
    ips_derivada_id text,
    tipo_alerta text NOT NULL,
    nivel_prioridad text NOT NULL,
    mensaje text NOT NULL,
    sintomas jsonb,
    coordenadas_alerta jsonb,
    resuelta boolean DEFAULT false NOT NULL,
    fecha_resolucion timestamp(3) without time zone,
    generado_por_id text,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado text DEFAULT 'pendiente'::text,
    es_automatica boolean DEFAULT false NOT NULL,
    score_riesgo integer
);


ALTER TABLE public.alertas OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 147922)
-- Name: contactos_emergencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contactos_emergencia (
    id text NOT NULL,
    gestante_id text NOT NULL,
    nombre text NOT NULL,
    parentesco text,
    telefono text NOT NULL,
    email text,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.contactos_emergencia OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 147940)
-- Name: contenidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contenidos (
    id text NOT NULL,
    titulo text NOT NULL,
    descripcion text,
    categoria text NOT NULL,
    url_contenido text,
    url_imagen text,
    duracion_minutos integer,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL,
    destacado boolean DEFAULT false NOT NULL,
    "destacadoEnSemanaGestacion" boolean DEFAULT false,
    nivel text,
    semana_gestacion_fin integer,
    semana_gestacion_inicio integer,
    tags jsonb,
    tipo text NOT NULL,
    url_video text
);


ALTER TABLE public.contenidos OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 148120)
-- Name: control_prenatal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.control_prenatal (
    id text NOT NULL,
    gestante_id text NOT NULL,
    medico_id text,
    fecha_control timestamp(3) without time zone NOT NULL,
    semanas_gestacion integer,
    peso double precision,
    altura_uterina double precision,
    presion_sistolica integer,
    presion_diastolica integer,
    frecuencia_cardiaca integer,
    frecuencia_respiratoria integer,
    temperatura double precision,
    movimientos_fetales text,
    edemas text,
    proteinuria text,
    glucosuria text,
    hallazgos jsonb,
    recomendaciones text,
    proximo_control timestamp(3) without time zone,
    realizado boolean DEFAULT false NOT NULL,
    observaciones text,
    examenes_solicitados jsonb,
    resultados_examenes jsonb,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.control_prenatal OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 147904)
-- Name: controles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.controles (
    id text NOT NULL,
    gestante_id text NOT NULL,
    medico_id text,
    fecha_control timestamp(3) without time zone NOT NULL,
    semanas_gestacion integer,
    peso double precision,
    altura_uterina double precision,
    presion_sistolica integer,
    presion_diastolica integer,
    frecuencia_cardiaca integer,
    frecuencia_respiratoria integer,
    temperatura double precision,
    movimientos_fetales text,
    edemas text,
    proteinuria text,
    glucosuria text,
    hallazgos jsonb,
    recomendaciones text,
    proximo_control timestamp(3) without time zone,
    realizado boolean DEFAULT false NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.controles OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 148194)
-- Name: conversaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversaciones (
    id text NOT NULL,
    tipo text NOT NULL,
    nombre text,
    descripcion text,
    participantes jsonb NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    ultimo_mensaje_id text,
    fecha_ultimo_mensaje timestamp(3) without time zone,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.conversaciones OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 148138)
-- Name: dispositivos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispositivos (
    id text NOT NULL,
    usuario_id text NOT NULL,
    device_id text NOT NULL,
    device_name text,
    platform text,
    app_version text,
    last_sync timestamp(3) without time zone,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.dispositivos OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 148176)
-- Name: entity_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_versions (
    id text NOT NULL,
    entidad text NOT NULL,
    entidad_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    checksum text,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.entity_versions OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 147895)
-- Name: gestantes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gestantes (
    id text NOT NULL,
    documento text,
    tipo_documento text,
    nombre text NOT NULL,
    fecha_nacimiento timestamp(3) without time zone NOT NULL,
    telefono text,
    direccion text,
    coordenadas jsonb,
    fecha_ultima_menstruacion timestamp(3) without time zone,
    fecha_probable_parto timestamp(3) without time zone,
    eps text,
    regimen_salud text NOT NULL,
    municipio_id text,
    madrina_id text,
    medico_tratante_id text,
    ips_asignada_id text,
    activa boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL,
    riesgo_alto boolean DEFAULT false NOT NULL
);


ALTER TABLE public.gestantes OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 147877)
-- Name: ips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ips (
    id text NOT NULL,
    nombre text NOT NULL,
    nit text,
    telefono text,
    direccion text,
    municipio_id text,
    nivel text,
    email text,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL,
    latitud numeric(10,8),
    longitud numeric(11,8)
);


ALTER TABLE public.ips OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 147949)
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id text NOT NULL,
    tipo text NOT NULL,
    mensaje text NOT NULL,
    datos jsonb,
    nivel text NOT NULL,
    usuario_id text,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 147886)
-- Name: medicos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicos (
    id text NOT NULL,
    nombre text NOT NULL,
    documento text,
    telefono text,
    especialidad text,
    email text,
    registro_medico text,
    ips_id text,
    municipio_id text,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL,
    tipo_documento text DEFAULT 'cedula'::text
);


ALTER TABLE public.medicos OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 148203)
-- Name: mensajes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mensajes (
    id text NOT NULL,
    conversacion_id text NOT NULL,
    remitente_id text NOT NULL,
    contenido text NOT NULL,
    tipo text DEFAULT 'texto'::text NOT NULL,
    archivo_url text,
    metadata jsonb,
    leido boolean DEFAULT false NOT NULL,
    fecha_lectura timestamp(3) without time zone,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.mensajes OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 147857)
-- Name: municipios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.municipios (
    id text NOT NULL,
    nombre text NOT NULL,
    departamento text NOT NULL,
    codigo_dane text,
    latitud numeric(10,8),
    longitud numeric(11,8),
    poblacion integer,
    area_km2 numeric(10,2),
    altitud_msnm integer,
    es_capital boolean DEFAULT false NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.municipios OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 148110)
-- Name: progreso_contenido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.progreso_contenido (
    id text NOT NULL,
    usuario_id text NOT NULL,
    contenido_id text NOT NULL,
    completado boolean DEFAULT false NOT NULL,
    porcentaje_progreso integer DEFAULT 0 NOT NULL,
    tiempo_visto integer,
    fecha_inicio timestamp(3) without time zone,
    fecha_completado timestamp(3) without time zone,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.progreso_contenido OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 148129)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id text NOT NULL,
    token text NOT NULL,
    usuario_id text NOT NULL,
    device_id text,
    expires_at timestamp(3) without time zone NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    revoked_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 147931)
-- Name: seguimiento_emergencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seguimiento_emergencia (
    id text NOT NULL,
    alerta_id text NOT NULL,
    gestante_id text NOT NULL,
    tipo text NOT NULL,
    estado text NOT NULL,
    notificaciones_enviadas integer DEFAULT 0 NOT NULL,
    detalles_notificaciones jsonb,
    observaciones text,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.seguimiento_emergencia OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 148167)
-- Name: sync_conflicts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_conflicts (
    id text NOT NULL,
    entidad text NOT NULL,
    entidad_id text NOT NULL,
    usuario_id text NOT NULL,
    device_id text NOT NULL,
    datos_local jsonb NOT NULL,
    datos_servidor jsonb NOT NULL,
    tipo_conflicto text NOT NULL,
    estado text DEFAULT 'pending'::text NOT NULL,
    resolucion jsonb,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_resolucion timestamp(3) without time zone
);


ALTER TABLE public.sync_conflicts OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 148147)
-- Name: sync_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_logs (
    id text NOT NULL,
    usuario_id text,
    device_id text,
    tipo_operacion text NOT NULL,
    entidad text NOT NULL,
    entidad_id text,
    estado text NOT NULL,
    detalles jsonb,
    error_message text,
    fecha_inicio timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_fin timestamp(3) without time zone,
    duracion_ms integer
);


ALTER TABLE public.sync_logs OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 148155)
-- Name: sync_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sync_queue (
    id text NOT NULL,
    usuario_id text NOT NULL,
    device_id text NOT NULL,
    entidad text NOT NULL,
    entidad_id text NOT NULL,
    operacion text NOT NULL,
    datos jsonb NOT NULL,
    prioridad integer DEFAULT 1 NOT NULL,
    intentos integer DEFAULT 0 NOT NULL,
    max_intentos integer DEFAULT 3 NOT NULL,
    estado text DEFAULT 'pending'::text NOT NULL,
    error_message text,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_procesamiento timestamp(3) without time zone
);


ALTER TABLE public.sync_queue OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 147867)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id text NOT NULL,
    nombre text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    documento text,
    tipo_documento text DEFAULT 'cedula'::text,
    rol text NOT NULL,
    municipio_id text,
    telefono text,
    activo boolean DEFAULT true NOT NULL,
    ultimo_acceso timestamp(3) without time zone,
    refresh_token text,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 148185)
-- Name: zonas_cobertura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zonas_cobertura (
    id text NOT NULL,
    nombre text NOT NULL,
    descripcion text,
    tipo text NOT NULL,
    centro_latitud numeric(10,8),
    centro_longitud numeric(11,8),
    radio_km double precision,
    coordenadas_poligono jsonb,
    municipio_id text,
    activa boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.zonas_cobertura OWNER TO postgres;

--
-- TOC entry 6439 (class 0 OID 147848)
-- Dependencies: 222
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
7a4eed6b-cc42-482b-9f51-067c2f3a0e1c	466cc7e63fa98e4ecb62192daf7c150e5bf86852510fc5c02a4fcfd20b572b8f	2025-10-21 21:05:03.648631-05	20251021234311_add_documento_to_usuario	\N	\N	2025-10-21 21:05:03.352052-05	1
43745ce1-4ff0-439d-bc21-1d30f0ee9491	97f43cb80cdb36acb3fd7d371cd0c79aaa50df4d0e789899b9674e56b0db84f3	2025-10-21 21:05:03.658901-05	20251021234630_add_tipo_documento_to_medico	\N	\N	2025-10-21 21:05:03.651468-05	1
e4ca2792-84b0-4d19-bdbb-c32ae967d1ad	0d56cf7e740e01cca1afba5c1064cf95e6cc8b08118c6a5dfd0d2686c5d09531	2025-10-21 21:05:03.874893-05	20251021235348_add_missing_tables_complete	\N	\N	2025-10-21 21:05:03.662464-05	1
d2bbf477-ee99-4e43-842b-1123e6343627	67b6144492574e5f5f298d15c700e4de742fbd9446bef443d27a6aff9d1b1787	2025-10-21 21:05:08.373822-05	20251022020508_add_documento_to_usuario	\N	\N	2025-10-21 21:05:08.358601-05	1
8d30d5f4-6e08-406a-8f73-86ae7f6a6a81	499b6c8b17cb9a871bfd25adafa48b26d2b38fabb38bd955b74442e11f3a0dcf	2025-10-21 23:44:15.33971-05	20251022044415_add_coordinates_to_ips	\N	\N	2025-10-21 23:44:15.331241-05	1
09af9401-6c8e-4ff2-83b8-e3f6a673eb86	e23ce006770e15909f8d310fb1d1cd319750b9c70475c56350c6d1c75b69b867	2025-10-22 00:40:39.967335-05	20251022054039_add_score_and_automatic_fields_to_alertas	\N	\N	2025-10-22 00:40:39.954799-05	1
\.


--
-- TOC entry 6446 (class 0 OID 147913)
-- Dependencies: 229
-- Data for Name: alertas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alertas (id, gestante_id, madrina_id, medico_asignado_id, ips_derivada_id, tipo_alerta, nivel_prioridad, mensaje, sintomas, coordenadas_alerta, resuelta, fecha_resolucion, generado_por_id, fecha_creacion, fecha_actualizacion, created_at, estado, es_automatica, score_riesgo) FROM stdin;
cmh3mwt4x0002lk76h3k8k44x	cmh2vubfo0001h63yrlob2411	\N	\N	\N	hipertension_severa	critica	Presión arterial crítica: 90/130 mmHg	[]	\N	f	\N	cmh1dl1ke0000jwml8gwsr8ll	2025-10-23 16:26:30.652	2025-10-23 16:26:30.652	2025-10-23 16:26:30.657	pendiente	f	0
\.


--
-- TOC entry 6447 (class 0 OID 147922)
-- Dependencies: 230
-- Data for Name: contactos_emergencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contactos_emergencia (id, gestante_id, nombre, parentesco, telefono, email, activo, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6449 (class 0 OID 147940)
-- Dependencies: 232
-- Data for Name: contenidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contenidos (id, titulo, descripcion, categoria, url_contenido, url_imagen, duracion_minutos, activo, fecha_creacion, fecha_actualizacion, destacado, "destacadoEnSemanaGestacion", nivel, semana_gestacion_fin, semana_gestacion_inicio, tags, tipo, url_video) FROM stdin;
cmh3zs6up00003rwgwdftahx8	Nutrición durante el embarazo	Guía completa sobre alimentación saludable durante el embarazo. Aprende qué alimentos consumir y cuáles evitar para el bienestar de tu bebé.	nutricion	https://www.youtube.com/watch?v=dQw4w9WgXcQ	https://via.placeholder.com/640x360/4CAF50/FFFFFF?text=Nutrición	10	t	2025-10-23 22:26:50.161	2025-10-23 22:26:50.161	t	f	basico	42	1	["nutricion", "embarazo", "alimentacion", "salud"]	video	https://www.youtube.com/watch?v=dQw4w9WgXcQ
cmh3zs6v100013rwghj5qiryq	Signos de alarma en el embarazo	Identifica los signos de alarma que requieren atención médica inmediata durante el embarazo.	signos_alarma	https://www.youtube.com/watch?v=dQw4w9WgXcQ	https://via.placeholder.com/640x360/F44336/FFFFFF?text=Signos+Alarma	8	t	2025-10-23 22:26:50.173	2025-10-23 22:26:50.173	t	f	basico	42	1	["signos", "alarma", "emergencia", "salud"]	video	https://www.youtube.com/watch?v=dQw4w9WgXcQ
cmh3zs6v400023rwgrl982nvu	Ejercicios para embarazadas	Rutina de ejercicios seguros y beneficiosos durante el embarazo para mantenerte activa y saludable.	ejercicio	https://www.youtube.com/watch?v=dQw4w9WgXcQ	https://via.placeholder.com/640x360/2196F3/FFFFFF?text=Ejercicios	15	t	2025-10-23 22:26:50.176	2025-10-23 22:26:50.176	f	f	intermedio	42	1	["ejercicio", "actividad", "salud", "bienestar"]	video	https://www.youtube.com/watch?v=dQw4w9WgXcQ
cmh3zs6v900033rwg921bqq0e	Meditación para embarazadas	Sesión de meditación guiada para reducir el estrés y conectar con tu bebé.	salud_mental	https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3	https://via.placeholder.com/640x360/9C27B0/FFFFFF?text=Meditación	10	t	2025-10-23 22:26:50.182	2025-10-23 22:26:50.182	t	f	basico	42	1	["meditacion", "relajacion", "salud mental", "bienestar"]	audio	\N
cmh3zs6ve00043rwgzdvgxonw	Preparación para el parto	Todo lo que necesitas saber para prepararte física y emocionalmente para el momento del parto.	parto	https://example.com/articulos/preparacion-parto.html	https://via.placeholder.com/640x360/FF9800/FFFFFF?text=Parto	\N	t	2025-10-23 22:26:50.186	2025-10-23 22:26:50.186	f	f	intermedio	42	20	["parto", "preparacion", "nacimiento"]	articulo	\N
cmh3zs6vh00053rwgafq2ptd4	Lactancia materna exitosa	Guía completa sobre técnicas de lactancia, posiciones, y solución de problemas comunes.	lactancia	https://example.com/articulos/lactancia.html	https://via.placeholder.com/640x360/00BCD4/FFFFFF?text=Lactancia	\N	t	2025-10-23 22:26:50.19	2025-10-23 22:26:50.19	t	f	basico	42	30	["lactancia", "amamantar", "bebe", "nutricion"]	articulo	\N
cmh3zs6vk00063rwgzghfifwq	Calendario de controles prenatales	Infografía visual con el calendario completo de controles prenatales recomendados.	cuidado_prenatal	https://via.placeholder.com/1200x1600/4CAF50/FFFFFF?text=Calendario+Controles	https://via.placeholder.com/640x360/4CAF50/FFFFFF?text=Calendario	\N	t	2025-10-23 22:26:50.193	2025-10-23 22:26:50.193	f	f	basico	42	1	["controles", "calendario", "prenatal", "seguimiento"]	infografia	\N
cmh3zs6vo00073rwgmron6qgy	Derechos de la gestante	Conoce tus derechos como gestante en Colombia: licencias, atención médica, y protección laboral.	derechos	https://via.placeholder.com/1200x1600/673AB7/FFFFFF?text=Derechos+Gestante	https://via.placeholder.com/640x360/673AB7/FFFFFF?text=Derechos	\N	t	2025-10-23 22:26:50.196	2025-10-23 22:26:50.196	t	f	basico	42	1	["derechos", "legal", "proteccion", "laboral"]	infografia	\N
cmh3zs6vr00083rwgoj8ac0l3	Guía de cuidados posparto	Documento completo con recomendaciones para el cuidado de la madre y el bebé después del parto.	posparto	https://example.com/documentos/cuidados-posparto.pdf	https://via.placeholder.com/640x360/E91E63/FFFFFF?text=Posparto	\N	t	2025-10-23 22:26:50.199	2025-10-23 22:26:50.199	f	f	intermedio	42	30	["posparto", "cuidados", "recuperacion", "bebe"]	documento	\N
cmh3zs6vu00093rwgn2vgpet7	Métodos de planificación familiar	Información detallada sobre los diferentes métodos anticonceptivos disponibles después del parto.	planificacion	https://example.com/documentos/planificacion-familiar.pdf	https://via.placeholder.com/640x360/009688/FFFFFF?text=Planificación	\N	t	2025-10-23 22:26:50.202	2025-10-23 22:26:50.202	f	f	intermedio	42	30	["planificacion", "anticonceptivos", "familia", "salud"]	documento	\N
cmh41cqae0000km3nbhsia3sr	Nutrición durante el embarazo	Guía completa sobre alimentación saludable durante el embarazo. Aprende qué alimentos consumir y cuáles evitar para el bienestar de tu bebé.	nutricion	https://www.youtube.com/watch?v=dQw4w9WgXcQ	https://via.placeholder.com/640x360/4CAF50/FFFFFF?text=Nutrición	10	t	2025-10-23 23:10:48.086	2025-10-23 23:10:48.086	t	f	basico	42	1	["nutricion", "embarazo", "alimentacion", "salud"]	video	https://www.youtube.com/watch?v=dQw4w9WgXcQ
cmh41cqak0001km3ncm3046hk	Signos de alarma en el embarazo	Identifica los signos de alarma que requieren atención médica inmediata durante el embarazo.	signos_alarma	https://www.youtube.com/watch?v=dQw4w9WgXcQ	https://via.placeholder.com/640x360/F44336/FFFFFF?text=Signos+Alarma	8	t	2025-10-23 23:10:48.092	2025-10-23 23:10:48.092	t	f	basico	42	1	["signos", "alarma", "emergencia", "salud"]	video	https://www.youtube.com/watch?v=dQw4w9WgXcQ
cmh41cqan0002km3n34vj0i48	Ejercicios para embarazadas	Rutina de ejercicios seguros y beneficiosos durante el embarazo para mantenerte activa y saludable.	ejercicio	https://www.youtube.com/watch?v=dQw4w9WgXcQ	https://via.placeholder.com/640x360/2196F3/FFFFFF?text=Ejercicios	15	t	2025-10-23 23:10:48.095	2025-10-23 23:10:48.095	f	f	intermedio	42	1	["ejercicio", "actividad", "salud", "bienestar"]	video	https://www.youtube.com/watch?v=dQw4w9WgXcQ
cmh41cqap0003km3ny8tlegsj	Meditación para embarazadas	Sesión de meditación guiada para reducir el estrés y conectar con tu bebé.	salud_mental	https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3	https://via.placeholder.com/640x360/9C27B0/FFFFFF?text=Meditación	10	t	2025-10-23 23:10:48.098	2025-10-23 23:10:48.098	t	f	basico	42	1	["meditacion", "relajacion", "salud mental", "bienestar"]	audio	\N
cmh41cqau0004km3nobruqas9	Preparación para el parto	Todo lo que necesitas saber para prepararte física y emocionalmente para el momento del parto.	parto	https://example.com/articulos/preparacion-parto.html	https://via.placeholder.com/640x360/FF9800/FFFFFF?text=Parto	\N	t	2025-10-23 23:10:48.103	2025-10-23 23:10:48.103	f	f	intermedio	42	20	["parto", "preparacion", "nacimiento"]	articulo	\N
cmh41cqax0005km3nnr1j4bjv	Lactancia materna exitosa	Guía completa sobre técnicas de lactancia, posiciones, y solución de problemas comunes.	lactancia	https://example.com/articulos/lactancia.html	https://via.placeholder.com/640x360/00BCD4/FFFFFF?text=Lactancia	\N	t	2025-10-23 23:10:48.106	2025-10-23 23:10:48.106	t	f	basico	42	30	["lactancia", "amamantar", "bebe", "nutricion"]	articulo	\N
cmh41cqb00006km3ncday4ayl	Calendario de controles prenatales	Infografía visual con el calendario completo de controles prenatales recomendados.	cuidado_prenatal	https://via.placeholder.com/1200x1600/4CAF50/FFFFFF?text=Calendario+Controles	https://via.placeholder.com/640x360/4CAF50/FFFFFF?text=Calendario	\N	t	2025-10-23 23:10:48.109	2025-10-23 23:10:48.109	f	f	basico	42	1	["controles", "calendario", "prenatal", "seguimiento"]	infografia	\N
cmh41cqb30007km3nli1hp5gh	Derechos de la gestante	Conoce tus derechos como gestante en Colombia: licencias, atención médica, y protección laboral.	derechos	https://via.placeholder.com/1200x1600/673AB7/FFFFFF?text=Derechos+Gestante	https://via.placeholder.com/640x360/673AB7/FFFFFF?text=Derechos	\N	t	2025-10-23 23:10:48.112	2025-10-23 23:10:48.112	t	f	basico	42	1	["derechos", "legal", "proteccion", "laboral"]	infografia	\N
cmh41cqb60008km3nty9exn13	Guía de cuidados posparto	Documento completo con recomendaciones para el cuidado de la madre y el bebé después del parto.	posparto	https://example.com/documentos/cuidados-posparto.pdf	https://via.placeholder.com/640x360/E91E63/FFFFFF?text=Posparto	\N	t	2025-10-23 23:10:48.114	2025-10-23 23:10:48.114	f	f	intermedio	42	30	["posparto", "cuidados", "recuperacion", "bebe"]	documento	\N
cmh41cqba0009km3nrpgrm7i2	Métodos de planificación familiar	Información detallada sobre los diferentes métodos anticonceptivos disponibles después del parto.	planificacion	https://example.com/documentos/planificacion-familiar.pdf	https://via.placeholder.com/640x360/009688/FFFFFF?text=Planificación	\N	t	2025-10-23 23:10:48.118	2025-10-23 23:10:48.118	f	f	intermedio	42	30	["planificacion", "anticonceptivos", "familia", "salud"]	documento	\N
cmh5gfwgn0000116b9eizpvdr	video	prueba excel	parto	/uploads/video-1761346856297-e55c835f-c58a-407a-8140-19ab998215f8.mp4	\N	\N	t	2025-10-24 23:00:56.471	2025-10-24 23:00:56.471	f	f	basico	\N	\N	[]	video	\N
cmh6q7znw0000nt6y3ou8n4lh	Contenido de prueba	Descripción de prueba	educacion	https://example.com/video.mp4	\N	\N	t	2025-10-25 20:22:29.708	2025-10-25 20:22:29.708	f	f	basico	\N	\N	[]	video	\N
cmh6qakd90001nt6ycrywejrh	Contenido de prueba	Descripción de prueba	educacion	https://example.com/video.mp4	\N	\N	t	2025-10-25 20:24:29.852	2025-10-25 20:24:29.852	f	f	basico	\N	\N	[]	video	\N
\.


--
-- TOC entry 6452 (class 0 OID 148120)
-- Dependencies: 235
-- Data for Name: control_prenatal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.control_prenatal (id, gestante_id, medico_id, fecha_control, semanas_gestacion, peso, altura_uterina, presion_sistolica, presion_diastolica, frecuencia_cardiaca, frecuencia_respiratoria, temperatura, movimientos_fetales, edemas, proteinuria, glucosuria, hallazgos, recomendaciones, proximo_control, realizado, observaciones, examenes_solicitados, resultados_examenes, fecha_creacion, fecha_actualizacion) FROM stdin;
control-001	gestante-001	medico-001	2024-06-15 00:00:00	8	58.5	\N	110	70	160	\N	\N	\N	ninguno	Negativa	Negativa	\N	Tomar ácido fólico diario. Asistir a controles mensuales.	2024-07-15 00:00:00	t	Primer control prenatal. Embarazo saludable.	\N	\N	2025-10-23 00:57:39.104	2025-10-23 00:57:39.104
control-002	gestante-001	medico-001	2024-07-15 00:00:00	12	60.2	10	115	75	155	\N	\N	\N	ninguno	Negativa	Negativa	\N	Continuar con vitaminas prenatales. Ejercicios moderados.	2024-08-15 00:00:00	t	Segundo control. Evolución normal.	\N	\N	2025-10-23 00:57:39.107	2025-10-23 00:57:39.107
control-003	gestante-001	medico-001	2024-08-15 00:00:00	16	62.8	15	118	78	150	\N	\N	\N	leve	Negativa	Negativa	\N	Elevar piernas al descansar. Reducir consumo de sal.	2024-09-15 00:00:00	t	Tercer control. Leve edema en tobillos.	\N	\N	2025-10-23 00:57:39.109	2025-10-23 00:57:39.109
control-004	gestante-002	medico-002	2024-07-15 00:00:00	8	55.2	\N	120	80	165	\N	\N	\N	ninguno	Negativa	Negativa	\N	Control estricto de presión arterial. Dieta baja en sodio.	2024-08-15 00:00:00	t	Primer control. Embarazo de alto riesgo por antecedentes.	\N	\N	2025-10-23 00:57:39.111	2025-10-23 00:57:39.111
control-005	gestante-002	medico-002	2024-08-15 00:00:00	12	57.8	10	125	85	160	\N	\N	\N	leve	Trazas	Negativa	\N	Reposo relativo. Control diario de presión en casa.	2024-09-01 00:00:00	t	Segundo control. Presión arterial elevada.	\N	\N	2025-10-23 00:57:39.112	2025-10-23 00:57:39.112
control-006	gestante-003	medico-003	2024-05-20 00:00:00	12	68.5	10	110	70	155	\N	\N	\N	ninguno	Negativa	Negativa	\N	Continuar con suplementos. Ejercicios suaves.	2024-06-20 00:00:00	t	Primer control. Embarazo saludable.	\N	\N	2025-10-23 00:57:39.114	2025-10-23 00:57:39.114
control-007	gestante-003	medico-003	2024-06-20 00:00:00	16	70.2	15	115	75	150	\N	\N	\N	ninguno	Negativa	Negativa	\N	Preparar para ecografía morfológica.	2024-07-20 00:00:00	t	Segundo control. Evolución normal.	\N	\N	2025-10-23 00:57:39.117	2025-10-23 00:57:39.117
control-008	gestante-004	medico-001	2024-08-01 00:00:00	8	62.3	\N	112	72	158	\N	\N	\N	ninguno	Negativa	Negativa	\N	Tomar ácido fólico. Asistir a clases de preparación al parto.	2024-09-01 00:00:00	t	Primer control. Embarazo saludable.	\N	\N	2025-10-23 00:57:39.119	2025-10-23 00:57:39.119
control-009	gestante-005	medico-003	2024-09-10 00:00:00	8	65.8	\N	118	78	162	\N	\N	\N	ninguno	Negativa	Negativa	\N	Estudios adicionales. Control estricto.	2024-10-10 00:00:00	t	Primer control. Embarazo de alto riesgo por edad materna.	\N	\N	2025-10-23 00:57:39.121	2025-10-23 00:57:39.121
cmh3mwsu40000lk766mosw0la	cmh2vubfo0001h63yrlob2411	c66fdb18-76f4-4767-95ad-9b4b81fa6add	2025-10-23 16:26:29.905	20	65	\N	90	130	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2025-10-23 16:26:30.268	2025-10-23 16:26:30.268
\.


--
-- TOC entry 6445 (class 0 OID 147904)
-- Dependencies: 228
-- Data for Name: controles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.controles (id, gestante_id, medico_id, fecha_control, semanas_gestacion, peso, altura_uterina, presion_sistolica, presion_diastolica, frecuencia_cardiaca, frecuencia_respiratoria, temperatura, movimientos_fetales, edemas, proteinuria, glucosuria, hallazgos, recomendaciones, proximo_control, realizado, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6460 (class 0 OID 148194)
-- Dependencies: 243
-- Data for Name: conversaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversaciones (id, tipo, nombre, descripcion, participantes, activa, ultimo_mensaje_id, fecha_ultimo_mensaje, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6454 (class 0 OID 148138)
-- Dependencies: 237
-- Data for Name: dispositivos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dispositivos (id, usuario_id, device_id, device_name, platform, app_version, last_sync, activo, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6458 (class 0 OID 148176)
-- Dependencies: 241
-- Data for Name: entity_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_versions (id, entidad, entidad_id, version, checksum, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6444 (class 0 OID 147895)
-- Dependencies: 227
-- Data for Name: gestantes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gestantes (id, documento, tipo_documento, nombre, fecha_nacimiento, telefono, direccion, coordenadas, fecha_ultima_menstruacion, fecha_probable_parto, eps, regimen_salud, municipio_id, madrina_id, medico_tratante_id, ips_asignada_id, activa, fecha_creacion, fecha_actualizacion, riesgo_alto) FROM stdin;
gestante-001	1234567890	cedula	María Elena Rodríguez García	1995-03-15 00:00:00	3101234567	Calle 12 #34-56, Barrio Centro	{"lat": 10.391, "lng": -75.4794}	2024-06-01 00:00:00	2025-03-08 00:00:00	SURA EPS	contributivo	13001	\N	medico-001	ips-001	t	2025-10-23 00:57:39.088	2025-10-23 00:57:39.088	f
gestante-002	2345678901	cedula	Ana Sofía Martínez López	1992-08-22 00:00:00	3102345678	Carrera 45 #67-89, Barrio La Esperanza	{"lat": 10.395, "lng": -75.485}	2024-07-15 00:00:00	2025-04-22 00:00:00	Nueva EPS	subsidiado	13001	\N	medico-002	ips-002	t	2025-10-23 00:57:39.092	2025-10-23 00:57:39.092	t
gestante-003	3456789012	cedula	Carmen Rosa Pérez Díaz	1988-12-10 00:00:00	3103456789	Avenida 78 #90-12, Barrio San José	{"lat": 10.4, "lng": -75.49}	2024-05-20 00:00:00	2025-02-26 00:00:00	Sanitas EPS	contributivo	13001	\N	medico-003	ips-003	t	2025-10-23 00:57:39.095	2025-10-23 00:57:39.095	f
gestante-004	4567890123	cedula	Laura Patricia Hernández Moreno	1990-05-18 00:00:00	3114567890	Calle 8 #23-45, Barrio Boston	{"lat": 10.405, "lng": -75.495}	2024-08-01 00:00:00	2025-05-08 00:00:00	Coomeva EPS	contributivo	13001	\N	medico-001	ips-001	t	2025-10-23 00:57:39.098	2025-10-23 00:57:39.098	f
gestante-005	5678901234	cedula	Diana Marcela Torres Peña	1993-11-30 00:00:00	3125678901	Carrera 15 #89-12, Barrio La Cima	{"lat": 10.41, "lng": -75.5}	2024-09-10 00:00:00	2025-06-17 00:00:00	SOS EPS	subsidiado	13001	\N	medico-003	ips-003	t	2025-10-23 00:57:39.101	2025-10-23 00:57:39.101	t
cmh2vubfo0001h63yrlob2411	45987456	cedula	liuba baliba	2000-10-28 05:00:00	3015847894	Turbaco Casa Loma	null	2025-09-22 05:00:00	2026-06-29 05:00:00	Sura	subsidiado	13836	\N	\N	\N	t	2025-10-23 03:48:44.77	2025-10-23 03:48:44.77	f
cmh6ol0o200022xq7ut7c9m34	1234567	cedula	Maria Paula	2000-10-31 05:00:00	3001234567	Chile	null	2025-09-27 05:00:00	2026-07-04 05:00:00	sanita	subsidiado	13140	\N	\N	\N	t	2025-10-25 19:36:38.306	2025-10-25 19:36:38.306	f
\.


--
-- TOC entry 6442 (class 0 OID 147877)
-- Dependencies: 225
-- Data for Name: ips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ips (id, nombre, nit, telefono, direccion, municipio_id, nivel, email, activo, fecha_creacion, fecha_actualizacion, latitud, longitud) FROM stdin;
ips-001	Clínica Madres Digitales	900123456-1	605-6543210	Calle 50 #25-30, Cartagena	13001	III	info@clinicamadresdigitales.com	t	2025-10-23 00:57:39.067	2025-10-23 00:57:39.067	\N	\N
ips-002	Hospital Universitario de Cartagena	900987654-2	605-6554321	Avenida Pedro de Heredia #30-65, Cartagena	13001	IV	info@hospitalucartagena.com	t	2025-10-23 00:57:39.073	2025-10-23 00:57:39.073	\N	\N
ips-003	Centro de Salud Turbaco	900456789-3	605-6565432	Carrera 10 #15-20, Turbaco	13042	II	info@saludturbaco.com	t	2025-10-23 00:57:39.075	2025-10-23 00:57:39.075	\N	\N
cmh2wtuyj0005te28tn2oklb9	IPS Prueba	900123456	3005879654	Arjona calle de coco	13052	primario	ipsprueba@gmail.com	t	2025-10-23 04:16:22.914	2025-10-23 04:16:22.914	10.45352040	-75.51601210
\.


--
-- TOC entry 6450 (class 0 OID 147949)
-- Dependencies: 233
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, tipo, mensaje, datos, nivel, usuario_id, fecha_creacion) FROM stdin;
\.


--
-- TOC entry 6443 (class 0 OID 147886)
-- Dependencies: 226
-- Data for Name: medicos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicos (id, nombre, documento, telefono, especialidad, email, registro_medico, ips_id, municipio_id, activo, fecha_creacion, fecha_actualizacion, tipo_documento) FROM stdin;
medico-001	Dr. Carlos Rodríguez	\N	300-1234567	Ginecología y Obstetricia	carlos.rodriguez@demo.com	123456	ips-001	13001	t	2025-10-23 00:57:39.078	2025-10-23 00:57:39.078	cedula
medico-002	Dra. María Fernanda Gómez	\N	300-2345678	Medicina Familiar	maria.gomez@demo.com	234567	ips-002	13001	t	2025-10-23 00:57:39.081	2025-10-23 00:57:39.081	cedula
medico-003	Dr. Luis Eduardo Pérez	\N	300-3456789	Pediatría	luis.perez@demo.com	345678	ips-003	13042	t	2025-10-23 00:57:39.083	2025-10-23 00:57:39.083	cedula
cmh2wl0kd0003te28vaqvfso1	Dr. Whatson	12345678	3001234567	Ginecologia	medico@prueba1.com	123456	\N	\N	t	2025-10-23 04:09:30.397	2025-10-23 04:09:30.397	cedula
\.


--
-- TOC entry 6461 (class 0 OID 148203)
-- Dependencies: 244
-- Data for Name: mensajes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mensajes (id, conversacion_id, remitente_id, contenido, tipo, archivo_url, metadata, leido, fecha_lectura, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6440 (class 0 OID 147857)
-- Dependencies: 223
-- Data for Name: municipios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.municipios (id, nombre, departamento, codigo_dane, latitud, longitud, poblacion, area_km2, altitud_msnm, es_capital, activo, fecha_creacion, fecha_actualizacion) FROM stdin;
13001	CARTAGENA DE INDIAS	BOLÍVAR	13001	10.38512600	-75.49626900	1028736	609.10	2	t	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13030	ALTOS DEL ROSARIO	BOLÍVAR	13030	8.79186500	-74.16490500	13263	234.00	180	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13042	ARENAL	BOLÍVAR	13042	8.45886500	-73.94109900	17009	664.00	80	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13052	ARJONA	BOLÍVAR	13052	10.25666000	-75.34433200	76433	376.00	10	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13062	ARROYOHONDO	BOLÍVAR	13062	10.25007500	-75.01921500	9439	278.00	15	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13074	BARRANCO DE LOBA	BOLÍVAR	13074	8.94778700	-74.10439100	18645	688.00	45	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13140	CALAMAR	BOLÍVAR	13140	10.25043100	-74.91614400	24517	536.00	8	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13160	CANTAGALLO	BOLÍVAR	13160	7.37867800	-73.91460500	10885	1676.00	75	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13188	CICUCO	BOLÍVAR	13188	9.27428100	-74.64598100	12403	525.00	25	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13222	CLEMENCIA	BOLÍVAR	13222	10.56745200	-75.32846900	13333	469.00	12	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13212	CÓRDOBA	BOLÍVAR	13212	9.58694200	-74.82739900	14659	300.00	20	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13244	EL CARMEN DE BOLÍVAR	BOLÍVAR	13244	9.71865300	-75.12117800	75320	954.00	154	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13248	EL GUAMO	BOLÍVAR	13248	10.03095800	-74.97608400	9687	84.00	8	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13268	EL PEÑÓN	BOLÍVAR	13268	8.98827100	-73.94927400	9681	418.00	60	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13300	HATILLO DE LOBA	BOLÍVAR	13300	8.95601400	-74.07791200	14710	517.00	40	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13430	MAGANGUÉ	BOLÍVAR	13430	9.26379900	-74.76674200	123692	1878.00	18	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13433	MAHATES	BOLÍVAR	13433	10.23328500	-75.19164300	24643	516.00	25	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13440	MARGARITA	BOLÍVAR	13440	9.15784000	-74.28513700	10202	356.00	30	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13442	MARÍA LA BAJA	BOLÍVAR	13442	9.98240200	-75.30051600	49832	673.00	6	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13458	MONTECRISTO	BOLÍVAR	13458	8.29723400	-74.47117600	20362	1073.00	90	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13473	MORALES	BOLÍVAR	13473	8.27655800	-73.86817200	15667	1357.00	110	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13490	NOROSÍ	BOLÍVAR	13490	8.52625900	-74.03800300	8524	710.00	55	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13549	PINILLOS	BOLÍVAR	13549	8.91494700	-74.46227900	26810	532.00	35	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13580	REGIDOR	BOLÍVAR	13580	8.66625800	-73.82163800	8190	491.00	85	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13600	RÍO VIEJO	BOLÍVAR	13600	8.58795000	-73.84046600	17621	662.00	70	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13620	SAN CRISTÓBAL	BOLÍVAR	13620	10.39283600	-75.06507600	7641	234.00	18	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13647	SAN ESTANISLAO	BOLÍVAR	13647	10.39860200	-75.15310100	17049	533.00	22	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13650	SAN FERNANDO	BOLÍVAR	13650	9.21418300	-74.32381100	14798	703.00	28	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13654	SAN JACINTO	BOLÍVAR	13654	9.83027500	-75.12105000	23420	469.00	201	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13655	SAN JACINTO DEL CAUCA	BOLÍVAR	13655	8.25158000	-74.72115600	12655	1631.00	45	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13657	SAN JUAN NEPOMUCENO	BOLÍVAR	13657	9.95375100	-75.08176100	36999	713.00	180	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13667	SAN MARTÍN DE LOBA	BOLÍVAR	13667	8.93748500	-74.03913400	22827	648.00	42	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13673	SANTA CATALINA	BOLÍVAR	13673	10.60529400	-75.28785500	12988	520.00	15	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13683	SANTA ROSA	BOLÍVAR	13683	10.44439600	-75.36982400	15681	298.00	20	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13688	SANTA ROSA DEL SUR	BOLÍVAR	13688	7.96393800	-74.05224300	37946	1954.00	95	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13468	SANTA CRUZ DE MOMPOX	BOLÍVAR	13468	9.24424100	-74.42818000	42651	645.00	33	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13744	SIMITÍ	BOLÍVAR	13744	7.95391600	-73.94726400	18704	1590.00	80	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13760	SOPLAVIENTO	BOLÍVAR	13760	10.38839000	-75.13640400	11082	216.00	25	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13780	TALAIGUA NUEVO	BOLÍVAR	13780	9.30403000	-74.56747900	20747	458.00	22	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13810	TIQUISIO	BOLÍVAR	13810	8.55866600	-74.26292200	19798	1057.00	65	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13836	TURBACO	BOLÍVAR	13836	10.34831600	-75.42724900	118954	158.00	108	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13838	TURBANÁ	BOLÍVAR	13838	10.27458500	-75.44265000	15571	317.00	95	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13873	VILLANUEVA	BOLÍVAR	13873	10.44408900	-75.27561300	18105	282.00	18	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13894	ZAMBRANO	BOLÍVAR	13894	9.74630600	-74.81787900	8289	251.00	165	f	t	2025-10-21 22:48:09.528	2025-10-21 22:48:09.528
13670	SAN PABLO	BOLÍVAR	13670	7.47674700	-73.92460200	29931	2213.00	65	f	f	2025-10-21 22:48:09.528	2025-10-25 19:25:25.974
13006	ACHÍ	BOLÍVAR	13006	8.57010700	-74.55767600	23138	1188.00	50	f	f	2025-10-21 22:48:09.528	2025-10-25 20:34:42.639
\.


--
-- TOC entry 6451 (class 0 OID 148110)
-- Dependencies: 234
-- Data for Name: progreso_contenido; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.progreso_contenido (id, usuario_id, contenido_id, completado, porcentaje_progreso, tiempo_visto, fecha_inicio, fecha_completado, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6453 (class 0 OID 148129)
-- Dependencies: 236
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, token, usuario_id, device_id, expires_at, revoked, revoked_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6448 (class 0 OID 147931)
-- Dependencies: 231
-- Data for Name: seguimiento_emergencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seguimiento_emergencia (id, alerta_id, gestante_id, tipo, estado, notificaciones_enviadas, detalles_notificaciones, observaciones, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6124 (class 0 OID 149834)
-- Dependencies: 246
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- TOC entry 6457 (class 0 OID 148167)
-- Dependencies: 240
-- Data for Name: sync_conflicts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sync_conflicts (id, entidad, entidad_id, usuario_id, device_id, datos_local, datos_servidor, tipo_conflicto, estado, resolucion, fecha_creacion, fecha_resolucion) FROM stdin;
\.


--
-- TOC entry 6455 (class 0 OID 148147)
-- Dependencies: 238
-- Data for Name: sync_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sync_logs (id, usuario_id, device_id, tipo_operacion, entidad, entidad_id, estado, detalles, error_message, fecha_inicio, fecha_fin, duracion_ms) FROM stdin;
\.


--
-- TOC entry 6456 (class 0 OID 148155)
-- Dependencies: 239
-- Data for Name: sync_queue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sync_queue (id, usuario_id, device_id, entidad, entidad_id, operacion, datos, prioridad, intentos, max_intentos, estado, error_message, fecha_creacion, fecha_procesamiento) FROM stdin;
\.


--
-- TOC entry 6441 (class 0 OID 147867)
-- Dependencies: 224
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombre, email, password_hash, documento, tipo_documento, rol, municipio_id, telefono, activo, ultimo_acceso, refresh_token, fecha_creacion, fecha_actualizacion) FROM stdin;
cmh1dl1ma0001jwmlk7hefkv6	María Coordinadora	coordinador@madresdigitales.com	$2b$10$/uxNPsWZ91ofY8huGxI/eOisKS9OgAVOQhNRRBR8D6VCFGMXrvRRy	\N	cedula	coordinador	\N	3007654321	t	\N	\N	2025-10-22 02:29:52.882	2025-10-22 02:29:52.882
cmh1dl1o00002jwmlxapcgua2	Dr. Carlos Médico	medico@madresdigitales.com	$2b$10$ImtkXVkAIq.WTFVR5CNRNeER6bvHdTyWYZkT.36iMmmttZoTB3q92	\N	cedula	medico	\N	3009876543	t	\N	\N	2025-10-22 02:29:52.945	2025-10-22 02:29:52.945
cmh1dl1pq0003jwmls16r8569	Ana Madrina	madrina@madresdigitales.com	$2b$10$pGmwkFHA8yHQaOZOdfgzKu5VMa38qSRQtrw.ooYKDo5vSTA49O9Oi	\N	cedula	madrina	\N	3005555555	t	\N	\N	2025-10-22 02:29:53.007	2025-10-22 02:29:53.007
cmh1dl1rg0004jwmlpf9r7421	Admin Demo	admin@madresdigitales.com	$2b$10$msmFjAXVlEdHwpY5tOz.2OBy3r9wuB7i1Vlz0y5lKVL4X5R6ckDUK	\N	cedula	admin	\N	3004444444	t	2025-10-23 17:30:06.802	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtaDFkbDFyZzAwMDRqd21scGY5cjc0MjEiLCJlbWFpbCI6ImFkbWluQG1hZHJlc2RpZ2l0YWxlcy5jb20iLCJyb2wiOiJhZG1pbiIsImlhdCI6MTc2MTI0MDYwNiwiZXhwIjoxNzYzODMyNjA2LCJhdWQiOiJtYWRyZXMtZGlnaXRhbGVzLXVzZXJzIiwiaXNzIjoibWFkcmVzLWRpZ2l0YWxlcyJ9.qJPG4I68Q-oh_JGDeQkDlZmBj7XnvxiHkIfqPk2q0RM	2025-10-22 02:29:53.068	2025-10-23 17:30:06.905
cmh2j2c0b0001up01w1gq0k3i	Super Administrador Master	superadmin@demo.com	$2b$10$P7PLcVYgpfvmEgZflRkg3uenWhvpuL2lDEaoI8DE.cjtmtTQopGOS	11111111	cedula	super_admin	13001	3000000000	t	\N	\N	2025-10-22 21:51:03.739	2025-10-22 21:51:03.739
cmh2j2c1e0005up01ch0c469y	María Coordinadora	coordinador@demo.com	$2b$10$dcNOj1sgYDsMfc.XPejPOuPuZdnXVU.34FLuYCeGVw.821DfutMIS	23456789	cedula	coordinador	13001	3002345678	t	\N	\N	2025-10-22 21:51:03.794	2025-10-22 21:51:03.794
cmh2j2c1k0007up01ydkh0k62	Dr. Carlos Médico	medico@demo.com	$2b$10$V931mIpwOzyzc6vodnCy.O0ziJ/9BsbgRKN5tBIdRnWsBgFm4hZaK	34567890	cedula	medico	13001	3003456789	t	\N	\N	2025-10-22 21:51:03.8	2025-10-22 21:51:03.8
cmh2j2c1p0009up01tb81z0rt	Ana Madrina Comunitaria	madrina@demo.com	$2b$10$wdQxS4hTc4mXjsDyk0NbOeqXMNSFwg5XdOgZu1s4JNeqiP7312wba	45678901	cedula	madrina	13001	3004567890	t	\N	\N	2025-10-22 21:51:03.806	2025-10-22 21:51:03.806
cmh2j2c150003up01p94pgbmx	Administrador Sistema	admin@demo.com	$2b$10$5nIwOP.Crob2H4/vPEV0a.Dz4KwaZAG6oZdCBkBVEudVgsyA/NYKe	12345678	cedula	admin	13001	3001234567	t	2025-10-22 22:18:33.701	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtaDJqMmMxNTAwMDN1cDAxcDk0cGdibXgiLCJlbWFpbCI6ImFkbWluQGRlbW8uY29tIiwicm9sIjoiYWRtaW4iLCJpYXQiOjE3NjExNzE1MTMsImV4cCI6MTc2Mzc2MzUxMywiYXVkIjoibWFkcmVzLWRpZ2l0YWxlcy11c2VycyIsImlzcyI6Im1hZHJlcy1kaWdpdGFsZXMifQ.Wf23ED-KmBoY5qMVegcEGViLY7W5J8jSC-XT9OQDD2s	2025-10-22 21:51:03.786	2025-10-22 22:18:33.811
cmh535xyo0001xmc2cw1y3cj8	Pepito Perez Prieto	prueba11@gmail.com	$2b$10$zIAI0ZodcgqDjxVhm3x.B.DqOCr5KBRCr8RSmhqtr/OvgO6aEENPu	12345678	cedula	ADMIN	13430	3001234567	t	\N	\N	2025-10-24 16:49:16.847	2025-10-24 16:49:16.847
cmh6pktcc0001q6osn3erakjw	Test Admin	test_admin@example.com	$2b$10$cP9p6zh/LSE2O/sFjWM1Au/AKG4YVFA2ounOf2J2/pmCNvRp7dsiS	\N	cedula	admin	\N	\N	t	2025-10-25 20:33:49.842	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtaDZwa3RjYzAwMDFxNm9zbjNlcmFranciLCJlbWFpbCI6InRlc3RfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2wiOiJhZG1pbiIsImlhdCI6MTc2MTQyNDQyOSwiZXhwIjoxNzY0MDE2NDI5LCJhdWQiOiJtYWRyZXMtZGlnaXRhbGVzLXVzZXJzIiwiaXNzIjoibWFkcmVzLWRpZ2l0YWxlcyJ9.FdBky5Iv_cvaYRIqOpFzaRlWuXMLakof5oOxxjYotoE	2025-10-25 20:04:28.427	2025-10-25 20:33:49.844
cmh6oapie00002xq7gu55ydk3	Juan Benavides	jbenavides@madresdigitales.com	$2b$10$3GM5YhYJHpprqk5IAjIwQeeAJxHvTzWTpQuMYIx74Cs4f02UDXXSy	12345678	cedula	madrina	\N	3001234567	t	2025-10-25 22:26:02.09	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtaDZvYXBpZTAwMDAyeHE3Z3U1NXlkazMiLCJlbWFpbCI6ImpiZW5hdmlkZXNAbWFkcmVzZGlnaXRhbGVzLmNvbSIsInJvbCI6Im1hZHJpbmEiLCJpYXQiOjE3NjE0MzExNjIsImV4cCI6MTc2NDAyMzE2MiwiYXVkIjoibWFkcmVzLWRpZ2l0YWxlcy11c2VycyIsImlzcyI6Im1hZHJlcy1kaWdpdGFsZXMifQ.hgPQpGpgWJQUHVs1ebsBrtsoWKAEaaxOKESIARtAjAE	2025-10-25 19:28:37.152	2025-10-25 22:26:02.203
cmh1dl1ke0000jwml8gwsr8ll	Wilson Zuccardi	wzuccardi@gmail.com	$2b$10$qH.h.OZRbQFhdTRBike2Ge86DZXa0HMEQ.RhBhDgEobmmjMtKqPAS	\N	cedula	SUPER_ADMIN	\N	3001234567	t	2025-10-25 22:42:01.544	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtaDFkbDFrZTAwMDBqd21sOGd3c3I4bGwiLCJlbWFpbCI6Ind6dWNjYXJkaUBnbWFpbC5jb20iLCJyb2wiOiJzdXBlcl9hZG1pbiIsImlhdCI6MTc2MTQzMjEyMSwiZXhwIjoxNzY0MDI0MTIxLCJhdWQiOiJtYWRyZXMtZGlnaXRhbGVzLXVzZXJzIiwiaXNzIjoibWFkcmVzLWRpZ2l0YWxlcyJ9.7NZNX6n8u3t6YnAb69i2qZxLaG4ootLxU8_1U8UHjhI	2025-10-22 02:29:52.813	2025-10-25 22:42:01.675
user_1762479474809_soh3eqv90	Admin Test	admin@test.com	$2b$10$rtWjRnYwcN0d/BOVYohvXuPGOZzEcSb.WuLrrjPWkpSSr99cu3Yhm	\N	cedula	ADMIN	\N	\N	t	\N	\N	2025-11-06 20:37:54.811	2025-11-06 20:37:54.811
cmh6phh150000q6osq11xlxhx	Test Madrina	test_madrina@example.com	$2b$10$w9hp4cedaEbk22BtwTD0vuBDWr0CVycFEd8CStXjZp.Mu86hWssZq	\N	cedula	madrina	\N	\N	t	2025-10-25 20:23:23.922	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtaDZwaGgxNTAwMDBxNm9zcTExeGx4aHgiLCJlbWFpbCI6InRlc3RfbWFkcmluYUBleGFtcGxlLmNvbSIsInJvbCI6Im1hZHJpbmEiLCJpYXQiOjE3NjE0MjM4MDMsImV4cCI6MTc2NDAxNTgwMywiYXVkIjoibWFkcmVzLWRpZ2l0YWxlcy11c2VycyIsImlzcyI6Im1hZHJlcy1kaWdpdGFsZXMifQ.OHsoxZF1MppfN4HLOyQzdP3JZOD7W_IQadek5jWAWCg	2025-10-25 20:01:52.505	2025-10-25 20:23:23.924
user_1762479474870_lv6adcs6s	Madrina Test	madrina@test.com	$2b$10$KPqhHohlQsEv8BZ37D8UKukd38rASUY9VsULOoDCrrrrlAHhDz.rm	\N	cedula	MADRINA	\N	\N	t	\N	\N	2025-11-06 20:37:54.872	2025-11-06 20:37:54.872
user_1762479474933_4o2fcvnjl	Medico Test	medico@test.com	$2b$10$zAmf8fVbyB0W.qVi6Wj21.8RvoxQWpWGzEMKi4rOFM7/rQlBKAtBW	\N	cedula	MEDICO	\N	\N	t	\N	\N	2025-11-06 20:37:54.935	2025-11-06 20:37:54.935
user_1762479836034_9rahss8vo	Coordinador Test	coordinador@test.com	$2b$10$5qKEMQWpJBghkI8U2LADQuHcxCQV5ZuMnYbOncitiRvxluOrZdtLy	\N	cedula	COORDINADOR	\N	\N	t	\N	\N	2025-11-06 20:43:56.035	2025-11-06 20:43:56.035
\.


--
-- TOC entry 6459 (class 0 OID 148185)
-- Dependencies: 242
-- Data for Name: zonas_cobertura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zonas_cobertura (id, nombre, descripcion, tipo, centro_latitud, centro_longitud, radio_km, coordenadas_poligono, municipio_id, activa, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- TOC entry 6128 (class 0 OID 150780)
-- Dependencies: 257
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- TOC entry 6129 (class 0 OID 151112)
-- Dependencies: 302
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- TOC entry 6130 (class 0 OID 151122)
-- Dependencies: 304
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- TOC entry 6131 (class 0 OID 151132)
-- Dependencies: 306
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- TOC entry 6126 (class 0 OID 150594)
-- Dependencies: 251
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- TOC entry 6127 (class 0 OID 150606)
-- Dependencies: 252
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- TOC entry 6474 (class 0 OID 0)
-- Dependencies: 250
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: postgres
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- TOC entry 6201 (class 2606 OID 147856)
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 6218 (class 2606 OID 147921)
-- Name: alertas alertas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas
    ADD CONSTRAINT alertas_pkey PRIMARY KEY (id);


--
-- TOC entry 6221 (class 2606 OID 147930)
-- Name: contactos_emergencia contactos_emergencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contactos_emergencia
    ADD CONSTRAINT contactos_emergencia_pkey PRIMARY KEY (id);


--
-- TOC entry 6225 (class 2606 OID 147948)
-- Name: contenidos contenidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenidos
    ADD CONSTRAINT contenidos_pkey PRIMARY KEY (id);


--
-- TOC entry 6232 (class 2606 OID 148128)
-- Name: control_prenatal control_prenatal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.control_prenatal
    ADD CONSTRAINT control_prenatal_pkey PRIMARY KEY (id);


--
-- TOC entry 6216 (class 2606 OID 147912)
-- Name: controles controles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controles
    ADD CONSTRAINT controles_pkey PRIMARY KEY (id);


--
-- TOC entry 6251 (class 2606 OID 148202)
-- Name: conversaciones conversaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversaciones
    ADD CONSTRAINT conversaciones_pkey PRIMARY KEY (id);


--
-- TOC entry 6238 (class 2606 OID 148146)
-- Name: dispositivos dispositivos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivos
    ADD CONSTRAINT dispositivos_pkey PRIMARY KEY (id);


--
-- TOC entry 6247 (class 2606 OID 148184)
-- Name: entity_versions entity_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_versions
    ADD CONSTRAINT entity_versions_pkey PRIMARY KEY (id);


--
-- TOC entry 6213 (class 2606 OID 147903)
-- Name: gestantes gestantes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gestantes
    ADD CONSTRAINT gestantes_pkey PRIMARY KEY (id);


--
-- TOC entry 6209 (class 2606 OID 147885)
-- Name: ips ips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ips
    ADD CONSTRAINT ips_pkey PRIMARY KEY (id);


--
-- TOC entry 6227 (class 2606 OID 147956)
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- TOC entry 6211 (class 2606 OID 147894)
-- Name: medicos medicos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_pkey PRIMARY KEY (id);


--
-- TOC entry 6253 (class 2606 OID 148212)
-- Name: mensajes mensajes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes
    ADD CONSTRAINT mensajes_pkey PRIMARY KEY (id);


--
-- TOC entry 6203 (class 2606 OID 147866)
-- Name: municipios municipios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipios
    ADD CONSTRAINT municipios_pkey PRIMARY KEY (id);


--
-- TOC entry 6229 (class 2606 OID 148119)
-- Name: progreso_contenido progreso_contenido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progreso_contenido
    ADD CONSTRAINT progreso_contenido_pkey PRIMARY KEY (id);


--
-- TOC entry 6234 (class 2606 OID 148137)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 6223 (class 2606 OID 147939)
-- Name: seguimiento_emergencia seguimiento_emergencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seguimiento_emergencia
    ADD CONSTRAINT seguimiento_emergencia_pkey PRIMARY KEY (id);


--
-- TOC entry 6244 (class 2606 OID 148175)
-- Name: sync_conflicts sync_conflicts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_conflicts
    ADD CONSTRAINT sync_conflicts_pkey PRIMARY KEY (id);


--
-- TOC entry 6240 (class 2606 OID 148154)
-- Name: sync_logs sync_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_logs
    ADD CONSTRAINT sync_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 6242 (class 2606 OID 148166)
-- Name: sync_queue sync_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sync_queue
    ADD CONSTRAINT sync_queue_pkey PRIMARY KEY (id);


--
-- TOC entry 6207 (class 2606 OID 147876)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 6249 (class 2606 OID 148193)
-- Name: zonas_cobertura zonas_cobertura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zonas_cobertura
    ADD CONSTRAINT zonas_cobertura_pkey PRIMARY KEY (id);


--
-- TOC entry 6236 (class 1259 OID 148215)
-- Name: dispositivos_device_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX dispositivos_device_id_key ON public.dispositivos USING btree (device_id);


--
-- TOC entry 6245 (class 1259 OID 148216)
-- Name: entity_versions_entidad_entidad_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX entity_versions_entidad_entidad_id_key ON public.entity_versions USING btree (entidad, entidad_id);


--
-- TOC entry 6219 (class 1259 OID 156303)
-- Name: idx_alertas_madrina_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_alertas_madrina_fecha ON public.alertas USING btree (madrina_id, fecha_creacion DESC) WHERE (madrina_id IS NOT NULL);


--
-- TOC entry 6214 (class 1259 OID 156304)
-- Name: idx_gestantes_madrina; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gestantes_madrina ON public.gestantes USING btree (madrina_id) WHERE (madrina_id IS NOT NULL);


--
-- TOC entry 6204 (class 1259 OID 156307)
-- Name: idx_usuarios_municipio_rol; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usuarios_municipio_rol ON public.usuarios USING btree (municipio_id, rol) WHERE (municipio_id IS NOT NULL);


--
-- TOC entry 6230 (class 1259 OID 148213)
-- Name: progreso_contenido_usuario_id_contenido_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX progreso_contenido_usuario_id_contenido_id_key ON public.progreso_contenido USING btree (usuario_id, contenido_id);


--
-- TOC entry 6235 (class 1259 OID 148214)
-- Name: refresh_tokens_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX refresh_tokens_token_key ON public.refresh_tokens USING btree (token);


--
-- TOC entry 6205 (class 1259 OID 147957)
-- Name: usuarios_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX usuarios_email_key ON public.usuarios USING btree (email);


--
-- TOC entry 6282 (class 2606 OID 148008)
-- Name: alertas alertas_gestante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas
    ADD CONSTRAINT alertas_gestante_id_fkey FOREIGN KEY (gestante_id) REFERENCES public.gestantes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6283 (class 2606 OID 148013)
-- Name: alertas alertas_madrina_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas
    ADD CONSTRAINT alertas_madrina_id_fkey FOREIGN KEY (madrina_id) REFERENCES public.usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6284 (class 2606 OID 148018)
-- Name: contactos_emergencia contactos_emergencia_gestante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contactos_emergencia
    ADD CONSTRAINT contactos_emergencia_gestante_id_fkey FOREIGN KEY (gestante_id) REFERENCES public.gestantes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6280 (class 2606 OID 147998)
-- Name: controles controles_gestante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controles
    ADD CONSTRAINT controles_gestante_id_fkey FOREIGN KEY (gestante_id) REFERENCES public.gestantes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6281 (class 2606 OID 148003)
-- Name: controles controles_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controles
    ADD CONSTRAINT controles_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6276 (class 2606 OID 147993)
-- Name: gestantes gestantes_ips_asignada_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gestantes
    ADD CONSTRAINT gestantes_ips_asignada_id_fkey FOREIGN KEY (ips_asignada_id) REFERENCES public.ips(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6277 (class 2606 OID 147983)
-- Name: gestantes gestantes_madrina_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gestantes
    ADD CONSTRAINT gestantes_madrina_id_fkey FOREIGN KEY (madrina_id) REFERENCES public.usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6278 (class 2606 OID 147988)
-- Name: gestantes gestantes_medico_tratante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gestantes
    ADD CONSTRAINT gestantes_medico_tratante_id_fkey FOREIGN KEY (medico_tratante_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6279 (class 2606 OID 147978)
-- Name: gestantes gestantes_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gestantes
    ADD CONSTRAINT gestantes_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6273 (class 2606 OID 147963)
-- Name: ips ips_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ips
    ADD CONSTRAINT ips_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6274 (class 2606 OID 147968)
-- Name: medicos medicos_ips_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_ips_id_fkey FOREIGN KEY (ips_id) REFERENCES public.ips(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6275 (class 2606 OID 147973)
-- Name: medicos medicos_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6289 (class 2606 OID 148222)
-- Name: mensajes mensajes_conversacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes
    ADD CONSTRAINT mensajes_conversacion_id_fkey FOREIGN KEY (conversacion_id) REFERENCES public.conversaciones(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6287 (class 2606 OID 148217)
-- Name: progreso_contenido progreso_contenido_contenido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.progreso_contenido
    ADD CONSTRAINT progreso_contenido_contenido_id_fkey FOREIGN KEY (contenido_id) REFERENCES public.contenidos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6285 (class 2606 OID 148023)
-- Name: seguimiento_emergencia seguimiento_emergencia_alerta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seguimiento_emergencia
    ADD CONSTRAINT seguimiento_emergencia_alerta_id_fkey FOREIGN KEY (alerta_id) REFERENCES public.alertas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6286 (class 2606 OID 148028)
-- Name: seguimiento_emergencia seguimiento_emergencia_gestante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seguimiento_emergencia
    ADD CONSTRAINT seguimiento_emergencia_gestante_id_fkey FOREIGN KEY (gestante_id) REFERENCES public.gestantes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6272 (class 2606 OID 147958)
-- Name: usuarios usuarios_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6288 (class 2606 OID 148971)
-- Name: zonas_cobertura zonas_cobertura_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zonas_cobertura
    ADD CONSTRAINT zonas_cobertura_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 6438 (class 6104 OID 132650)
-- Name: madres_digitales; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION madres_digitales WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION madres_digitales OWNER TO postgres;

--
-- TOC entry 6468 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2025-11-06 23:17:13

--
-- PostgreSQL database dump complete
--

