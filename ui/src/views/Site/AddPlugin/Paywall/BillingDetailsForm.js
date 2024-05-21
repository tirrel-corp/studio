import { useForm } from 'react-hook-form';
import cn from 'clsx';
import countries from './countries.json';

const emptyValues = {
  name: '',
  line1: '',
  city: '',
  district: '',
  postalCode: '',
}

const BillingDetailsForm = props => {
  const { onSubmit, values = emptyValues } = props;

  const {
    register,
    handleSubmit,
    formState: { errors, touchedFields },
  } = useForm({
    mode: 'onBlur',
    defaultValues: values,
  });

  return (
    <>
      <p className="pb4">Wire transfers are currently only supported for accounts located in the United States.</p>
      <form
        className="w-100"
        id="step2-form"
        autoComplete="on"
        style={{ maxWidth: 'calc(min(30rem, 95vw))' }}
        onSubmit={handleSubmit(onSubmit)}
      >
        <span className="flex flex-wrap justify-between w-100 items-center" style={{ gap: '1.25rem' }}>
          <span className="w-100">
            <label className="f6 mb1 db" htmlFor="account">
              Account Number
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.account })}
              type="number"
              placeholder="12340010"
              id="account"
              {...register("account", {
                required: true,
                pattern: {
                  value: /(\d{8})/,
                  message: 'Bank account number'
                },
              })}
            />
            {errors?.account?.message && (
              <span className="f6 red">{errors?.account?.message}</span>
            )}
          </span>

          <span className="w-100">
            <label className="f6 mb1 db" htmlFor="route">
              Routing Number
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.route })}
              type="number"
              placeholder="121000248"
              id="route"
              {...register("route", {
                required: true,
                pattern: {
                  value: /(\d{9})/,
                  message: 'Bank routing number'
                },
              })}
            />
            {errors?.route?.message && (
              <span className="f6 red">{errors?.route?.message}</span>
            )}
          </span>

          <h2>Billing Details</h2>

          <span className="w-100">
            <label className="f6 mb1 db" htmlFor="name">
              Full name
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.name })}
              type="text"
              placeholder="John Smith"
              autoComplete="cc-given-name"
              id="name"
              {...register("name", {
                required: true,
                pattern: {
                  value: /(?:\w+ )+\w+/,
                  message: 'full name as it appears on your credit card'
                },
              })}
            />
            {errors?.name?.message && (
              <span className="f6 red">{errors?.name?.message}</span>
            )}
          </span>
          <span className="w-100">
            <label className="f6 mb1 db" htmlFor="address-line1">
              Billing Address
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.line1 })}
              type="text"
              placeholder="200 Cherry Ln"
              autoComplete="line1"
              id="line1"
              {...register("line1", {
                required: true,
              })}
            />
            <input
              className={cn('w-100 pa3 mt2 f5', { 'b--red': errors?.line2 })}
              type="text"
              placeholder="Line 2 (optional)"
              autoComplete="line2"
              id="line2"
              {...register("line2", {
                required: false,
              })}
            />
          </span>
          <span className="w-100">
            <label className="f6 mb1 db" htmlFor="city">
              City
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.city })}
              type="text"
              autoComplete="address-level2"
              placeholder="Verduria"
              id="city"
              {...register("city", {
                required: true,
              })}
            />
          </span>
          <span className="w-40">
            <label className="f6 mb1 db" htmlFor="district">
              State/District
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.district })}
              type="text"
              placeholder="MN"
              autoComplete="address-level1"
              id="district"
              {...register("district", {
                required: true,
              })}
            />
          </span>
          <span className="w-50">
            <label className="f6 mb1 db" htmlFor="postalCode">
              Postal code
            </label>
            <input
              className={cn('w-100 pa3 f5', { 'b--red': errors?.postalCode })}
              type="text"
              placeholder="88888"
              autoComplete="postal-code"
              id="postalCode"
              {...register("postalCode", {
                required: true,
              })}
            />
          </span>
        </span>
        <div className="mt4 w-100 flex justify-end">
          <button type="submit">Set</button>
        </div>
        <p className="mt4">You will be able to confirm before proceeding.</p>
      </form>
    </>
  )
};

export { BillingDetailsForm };
